class FundQueue < ActiveRecord::Base
  attr_accessible :advertised_submit_at, :submit_at, :release_at,
    :fund_request_type_ids, :release_message, :allocate_message
  attr_readonly :fund_source_id

  belongs_to :fund_source, inverse_of: :fund_queues

  has_many :fund_allocations, through: :fund_requests
  has_many :fund_requests, inverse_of: :fund_queue, dependent: :nullify do
    # Allocate all ready requests associated with this fund source
    def allocate!(cap = nil)
      with_review_state( :ready ).includes { [ fund_editions.fund_item,
        fund_grant.organization ] }.each { |r| r.fund_items.allocate! cap }
    end

    # Returns CSV spreadsheet representing requests assigned to this queue
    def reviews_report
      # This gives cumulative allocation per category for each request
      category_sql = proxy_association.owner.fund_source.structure.categories.map do |c|
        "(SELECT SUM(fund_allocations.amount) FROM fund_allocations " +
        "INNER JOIN fund_items ON fund_items.id = fund_allocations.fund_item_id " +
        "INNER JOIN nodes ON fund_items.node_id = nodes.id " +
        "WHERE nodes.category_id = #{c.id} AND " +
        "fund_allocations.fund_request_id = fund_requests.id) AS category#{c.id}"
      end.join(", ")
      rows = connection.select_rows <<-SQL
        SELECT TRIM(CONCAT(organizations.first_name, " ", organizations.last_name))
        AS name, (SELECT university_accounts.account_code
        FROM university_accounts WHERE organization_id = organizations.id
        ORDER BY active DESC LIMIT 1) AS account,
        (SELECT university_accounts.subaccount_code
        FROM university_accounts WHERE organization_id = organizations.id
        ORDER BY active DESC LIMIT 1) AS subaccount,
        (SELECT active
        FROM university_accounts WHERE organization_id = organizations.id
        ORDER BY active DESC LIMIT 1) AS subaccount_active,
        EXISTS(SELECT * FROM fund_requests AS r INNER JOIN fund_grants
        AS g ON r.fund_grant_id = g.id INNER JOIN returning_fund_sources AS rs
        ON g.fund_source_id = rs.returning_fund_source_id WHERE
        rs.fund_source_id = fund_grants.fund_source_id AND r.state = 'released'
        AND g.organization_id = fund_grants.organization_id)
        AS returning, (SELECT registered FROM registrations INNER JOIN
        registration_terms ON registrations.registration_term_id =
        registration_terms.id WHERE registration_terms.current = 1
        AND registrations.organization_id = organizations.id LIMIT 1) AS
        registered, (SELECT independent FROM registrations INNER JOIN
        registration_terms ON registrations.registration_term_id =
        registration_terms.id WHERE registration_terms.current = 1 AND
        registrations.organization_id = organizations.id LIMIT 1) AS
        independent, fund_requests.state,
        (SELECT fund_tiers.maximum_allocation FROM fund_tiers INNER JOIN
        fund_tier_assignments ON fund_tiers.id = fund_tier_assignments.fund_tier_id
        WHERE fund_tier_assignments.id = fund_grants.fund_tier_assignment_id LIMIT 1
        ) AS tier,
        (SELECT SUM(fund_editions.amount) FROM fund_editions WHERE perspective
        = 'requestor' AND fund_request_id = fund_requests.id ) AS request,
        (SELECT SUM(fund_editions.amount) FROM fund_editions WHERE perspective
        = 'reviewer' AND fund_request_id = fund_requests.id ) AS review,
        (SELECT SUM(fund_allocations.amount) FROM fund_items INNER JOIN
        fund_allocations ON fund_items.id = fund_allocations.fund_item_id
        WHERE fund_items.fund_grant_id = fund_grants.id ) AS cumulative_allocation,
        (SELECT SUM(fund_allocations.amount) FROM fund_items INNER JOIN
        fund_allocations ON fund_items.id = fund_allocations.fund_item_id
        WHERE fund_allocations.fund_request_id = fund_requests.id) AS queue_allocation
        #{category_sql.empty? ? "" : ", " + category_sql} FROM
        organizations INNER JOIN fund_grants ON organizations.id =
        fund_grants.organization_id INNER JOIN fund_requests ON
        fund_grants.id = fund_requests.fund_grant_id WHERE
        fund_requests.fund_queue_id = #{proxy_association.owner.id}
        ORDER BY organizations.last_name, organizations.first_name
      SQL
      CSV.generate do |csv|
        csv << ( %w( organization account subaccount active? returning?
          registered? independent? state tier request review cumulative_allocation
          queue_allocation ) + proxy_association.owner.fund_source.
          structure.categories.map(&:name) )
        rows.each { |row| csv << row }
      end
    end

    # Returns an array with rows representing different request review states.
    # For each row, contents are:
    # * review state name
    # * number of distinct requests in review state
    # * total requestor amounts for review state
    # * total reviewer amounts for review state
    def quantity_and_amount_report
      connection.select_rows(
        "SELECT fund_requests.review_state AS review_state, " +
        "COUNT(DISTINCT fund_requests.id) AS quantity, " +
        "SUM(requests.amount) AS request, " +
        "SUM(reviews.amount) AS review " +
        "FROM fund_grants INNER JOIN fund_requests ON fund_grants.id = fund_requests.fund_grant_id " +
        "LEFT JOIN fund_editions AS requests ON fund_requests.id = requests.fund_request_id " +
        "AND requests.perspective = #{connection.quote FundEdition::PERSPECTIVES.first} " +
        "LEFT JOIN fund_editions AS reviews ON requests.fund_request_id = reviews.fund_request_id " +
        "AND reviews.perspective = #{connection.quote FundEdition::PERSPECTIVES.last} " +
        "AND reviews.fund_item_id = requests.fund_item_id " +
        "WHERE fund_requests.fund_queue_id = #{proxy_association.owner.id} " +
        "GROUP BY fund_requests.review_state ORDER BY fund_requests.review_state"
      )
    end

  end
  has_many :fund_editions, through: :fund_requests, uniq: true
  has_many :fund_items, through: :fund_requests, uniq: true do
    # Allocate all ready requests associate with this fund queue
    # TODO: this does not work with discrete_allocations
    # * apply flat percentage cuts to reviewer amounts approved
    def allocate_with_cuts(percentage)
      where( "fund_requests.review_state = ?", 'ready' ).
      where( "fund_editions.perspective = ?", FundEdition::PERSPECTIVES.last ).
      update_all "fund_items.amount = fund_editions.amount*(#{percentage}/100)"
    end
  end
  has_many :fund_grants, through: :fund_requests, uniq: true do
    def ready
      where( "fund_requests.review_state = ?", 'ready' )
    end
  end

  has_and_belongs_to_many :fund_request_types

  default_scope order( 'fund_queues.submit_at ASC' )
  scope :past, lambda { where( :submit_at.lt => Time.zone.now ) }
  scope :future, lambda { where( :submit_at.gt => Time.zone.now ) }
  scope :advertised_after, lambda { |point|
    where { ( advertised_submit_at.eq( nil ) & submit_at.gt( point ) ) |
    ( advertised_submit_at.gt( point ) ) }
  }
  scope :advertised_before, lambda { |point|
    where { ( advertised_submit_at.eq( nil ) & submit_at.lt( point ) ) |
    ( advertised_submit_at.lt( point ) ) }
  }

  validates :fund_source, presence: true
  validates :submit_at, presence: true,
    uniqueness: { scope: :fund_source_id },
    timeliness: { type: :datetime, before: :release_at, after: :open_at }
  validates :advertised_submit_at, presence: true,
    timeliness: { type: :datetime, on_or_before: :submit_at }
  validates :release_at, presence: true,
    timeliness: { type: :datetime, after: :submit_at }

  before_validation do |queue|
    queue.advertised_submit_at = queue.submit_at if queue.advertised_submit_at.blank?
  end

  def open_at; fund_source.open_at if fund_source; end

  def closed_at; fund_source.closed_at if fund_source; end

  def to_s
    return super unless advertised_submit_at? || submit_at?
    return submit_at.to_s :rfc822 unless advertised_submit_at?
    if Time.zone.now < advertised_submit_at
      "#{advertised_submit_at.to_s(:rfc822)}"
    else
      "#{submit_at.to_s(:rfc822)} (extended from #{advertised_submit_at.to_s(:rfc822)})"
    end
  end

end

