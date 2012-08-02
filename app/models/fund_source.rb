class FundSource < ActiveRecord::Base
  attr_accessible :name, :framework_id, :structure_id, :contact_name,
    :contact_email, :open_at, :closed_at, :release_message, :contact_web,
    :fund_queues_attributes, :returning_fund_source_ids, :allocate_message,
    :fund_tier_ids
  attr_readonly :framework_id, :structure_id

  belongs_to :organization, inverse_of: :fund_sources
  belongs_to :structure, inverse_of: :fund_sources
  belongs_to :framework, inverse_of: :fund_sources
  has_many :activity_accounts, through: :fund_grants
  has_many :fund_allocations, through: :fund_requests
  has_many :fund_grants, dependent: :destroy, inverse_of: :fund_source do
    def build_for( organization )
      grant = build
      grant.organization = organization
      grant
    end
    def released_report
      category_sql = proxy_association.owner.structure.categories.map do |c|
        "(SELECT SUM(fund_allocations.amount) FROM fund_allocations " +
        "INNER JOIN fund_items ON fund_items.id = fund_allocations.fund_item_id " +
        "INNER JOIN nodes ON fund_items.node_id = nodes.id " +
        "WHERE fund_items.fund_grant_id = fund_grants.id AND " +
        "nodes.category_id = #{c.id} )"
      end.join(", ")
      rows = connection.execute <<-SQL
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
        registration_terms.id WHERE registration_terms.current = 1 AND
        registrations.organization_id = organizations.id LIMIT 1) AS registered,
        (SELECT independent FROM registrations INNER JOIN registration_terms ON
        registrations.registration_term_id = registration_terms.id WHERE
        registration_terms.current = 1 AND registrations.organization_id =
        organizations.id LIMIT 1) AS independent, (SELECT
        SUM(fund_allocations.amount) FROM fund_items INNER JOIN
        fund_allocations ON fund_items.id = fund_allocations.fund_item_id WHERE
        fund_items.fund_grant_id = fund_grants.id) AS allocation
        #{category_sql.blank? ? '' : ', ' + category_sql}
        FROM organizations INNER JOIN fund_grants ON organizations.id =
        fund_grants.organization_id WHERE
        fund_grants.fund_source_id = #{proxy_association.owner.id}
        ORDER BY organizations.last_name, organizations.first_name
      SQL
      CSV.generate do |csv|
        csv << (
          %w( organization account subaccount active? returning? registered?
            independent? allocation ) + proxy_association.owner.structure.
            categories.map(&:name)
        )
        rows.each { |row| csv << row }
      end
    end
  end
  has_many :fund_queues, inverse_of: :fund_source, dependent: :destroy do
    def active
      future.first
    end
  end
  has_many :fund_requests, through: :fund_grants do
    # Returns an array with rows representing different request states.
    # For each row, contents are:
    # * state name
    # * number of distinct requests in state
    # * total requestor amounts for state
    # * total reviewer amounts for state
    def quantity_and_amount_report
      connection.select_rows(
        "SELECT fund_requests.state AS state, " +
        "COUNT(DISTINCT fund_requests.id) AS quantity, " +
        "SUM(requests.amount) AS request, " +
        "SUM(reviews.amount) AS review " +
        "FROM fund_grants INNER JOIN fund_requests ON fund_grants.id = fund_requests.fund_grant_id " +
        "LEFT JOIN fund_editions AS requests ON fund_requests.id = requests.fund_request_id " +
        "AND requests.perspective = #{connection.quote FundEdition::PERSPECTIVES.first} " +
        "LEFT JOIN fund_editions AS reviews ON requests.fund_request_id = reviews.fund_request_id " +
        "AND reviews.perspective = #{connection.quote FundEdition::PERSPECTIVES.last} " +
        "AND reviews.fund_item_id = requests.fund_item_id " +
        "WHERE fund_grants.fund_source_id = #{proxy_association.owner.id} " +
        "GROUP BY fund_requests.state ORDER BY fund_requests.state"
      )
    end
  end
  has_many :fund_items, through: :fund_grants
  has_many :fund_request_types, through: :fund_queues do
    def upcoming
      scoped.where( FundQueue.arel_table[:submit_at].gt( Time.zone.now ) )
    end
  end
  has_and_belongs_to_many :returning_fund_sources, join_table: :returning_fund_sources,
    association_foreign_key: :returning_fund_source_id, class_name: 'FundSource'
  has_and_belongs_to_many :fund_tiers
  has_many :allowed_fund_tiers, through: :organization, source: :fund_tiers
  has_many :memberships, through: :organization, source: :active_memberships

  accepts_nested_attributes_for :fund_queues, allow_destroy: true,
    :reject_if => proc { |a|
      %w( submit_at release_at ).all? do |k|
        a[k].blank?
      end
    }

  validates :name, presence: true, uniqueness: true
  validates :organization, presence: true
  validates :framework, presence: true
  validates :structure, presence: true
  validates :contact_name, presence: true
  validates :contact_email,
    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :contact_web, presence: true
  validates :open_at, timeliness: { type: :datetime }
  validates :closed_at, timeliness: { type: :datetime, after: :open_at }

  scope :ordered, lambda { order { name } }
  scope :closed, lambda { where { closed_at.lt( Time.zone.now ) } }
  scope :current, lambda {
    where { open_at.lt( Time.zone.now ) & closed_at.gt( Time.zone.now ) }
  }
  scope :open_deadline, lambda {
    current.joins { fund_queues }.
    where { fund_queues.submit_at.gt( Time.zone.now ) }
  }
  scope :open_deadline_for_first, lambda {
    open_deadline.joins { fund_queues.fund_request_types }.
    where { fund_queues.fund_request_types.allowed_for_first.eq( true ) }
  }
  scope :upcoming, lambda { where { open_at.gt( Time.zone.now ) } }
  scope :no_fund_grant_for, lambda { |organization|
    where { id.not_in( FundGrant.unscoped.
      where { organization_id.eq( my { organization.id } ) }.
      select { fund_source_id }
    ) }
  }
  scope :fulfilled_for_memberships, lambda { |memberships|
    FundSource.where { framework_id.in(
      Framework.fulfilled_for_memberships( memberships ).select { id } ) }
  }
  scope :unfulfilled_for_memberships, lambda { |memberships|
    FundSource.where { framework_id.in(
      Framework.unfulfilled_for_memberships( memberships ).select { id } ) }
  }

  def contact_to_email; "#{contact_name} <#{contact_email}>"; end

  def upcoming?
    open_at > Time.zone.now
  end

  def closed?
    closed_at < Time.zone.now
  end

  def current?
    (open_at < Time.zone.now) && (closed_at > Time.zone.now)
  end

  def to_s; name; end
end

