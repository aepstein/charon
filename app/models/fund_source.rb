class FundSource < ActiveRecord::Base
  attr_accessible :name, :framework_id, :structure_id, :contact_name,
    :contact_email, :open_at, :closed_at, :release_message, :contact_web,
    :fund_queues_attributes, :returning_fund_source_ids
  attr_readonly :framework_id, :structure_id

  belongs_to :organization, :inverse_of => :fund_sources
  belongs_to :structure, :inverse_of => :fund_sources
  belongs_to :framework, :inverse_of => :fund_sources
  has_many :activity_accounts, :dependent => :destroy, :inverse_of => :fund_source
  has_many :fund_grants, :dependent => :destroy, :inverse_of => :fund_source do
    def build_for( organization )
      grant = build
      grant.organization = organization
      grant
    end
    def released_report
      category_sql = Category.all.map do |c|
        "(SELECT SUM(fund_items.released_amount) FROM fund_items " +
        "INNER JOIN nodes ON fund_items.node_id = nodes.id " +
        "WHERE fund_items.fund_grant_id = fund_grants.id AND " +
        "nodes.category_id = #{c.id} )"
      end.join(", ")
      rows = connection.execute <<-SQL
        SELECT TRIM(CONCAT(organizations.first_name, " ", organizations.last_name))
        AS name, EXISTS(SELECT * FROM fund_requests AS r INNER JOIN fund_grants
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
        organizations.id LIMIT 1) AS independent, BINARY
        organizations.club_sport, CONCAT(university_accounts.department_code,
        university_accounts.subledger_code, '-',
        university_accounts.subaccount_code) AS account,
        BINARY university_accounts.active, (SELECT
        SUM(fund_items.released_amount) FROM fund_items WHERE
        fund_items.fund_grant_id = fund_grants.id) AS allocation
        #{category_sql.blank? ? '' : ', ' + category_sql}
        FROM organizations INNER JOIN fund_grants ON organizations.id =
        fund_grants.organization_id LEFT JOIN university_accounts ON
        organizations.id = university_accounts.organization_id WHERE
        fund_grants.fund_source_id = #{@association.owner.id}
        ORDER BY organizations.last_name, organizations.first_name
      SQL
      CSV.generate do |csv|
        csv << (
          %w( organization returning? registered? independent? club_sport? account active? allocation ) +
          Category.all.map(&:name)
        )
        rows.each { |row| csv << row }
      end
    end
  end
  has_many :fund_queues, :inverse_of => :fund_source, :dependent => :destroy do
    def active
      future.first
    end
  end
  # TODO allocation methods need flexible_budgets rework
  has_many :fund_requests, :through => :fund_grants do

    # Allocate all requests associated with this fund source
    # * apply club_sport and other caps according to how organizations are recorded
    # * TODO: this method should be relocated to the fund_queue with which
    #   allocated requests are associated
    def allocate_with_caps(club_sport, other)
      with_state( :certified ).includes( :organization, { :fund_items => :fund_editions } ).each do |r|
        if r.organization.club_sport?
          r.fund_items.allocate club_sport
        else
          r.fund_items.allocate other
        end
      end
    end

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

    # TODO: relocate to queue, deduct amounts previously requested where appropriate
    def amount_for_perspective_and_status(perspective, status)
      sub = "SELECT fund_items.id FROM fund_items INNER JOIN fund_requests WHERE fund_request_id = fund_requests.id " +
            "AND fund_source_id = ? AND fund_requests.status = ?"
      FundEdition.where(:perspective => perspective).
        where( "fund_item_id IN (#{sub})", @association.owner.id, status ).sum( 'amount' )
    end

    # TODO: should be calculated through items
    def fund_item_amount_for_status(status)
      sub = "SELECT fund_items.id FROM fund_items INNER JOIN fund_requests WHERE fund_request_id = fund_requests.id " +
            "AND fund_source_id = ? AND fund_requests.status = ?"
      FundItem.where( "id IN (#{sub})", @association.owner.id, status ).sum( 'amount' )
    end
  end
  has_many :fund_items, :through => :fund_grants
  has_many :fund_request_types, :through => :fund_queues do
    def upcoming
      scoped.where( FundQueue.arel_table[:submit_at].gt( Time.zone.now ) )
    end
  end
  has_and_belongs_to_many :returning_fund_sources, join_table: :returning_fund_sources,
    association_foreign_key: :returning_fund_source_id, class_name: 'FundSource'

  accepts_nested_attributes_for :fund_queues, :allow_destroy => true,
    :reject_if => proc { |a|
      %w( submit_at release_at ).all? do |k|
        a[k].blank?
      end
    }

  validates :name, :presence => true, :uniqueness => true
  validates :organization, :presence => true
  validates :framework, :presence => true
  validates :structure, :presence => true
  validates :contact_name, :presence => true
  validates :contact_email,
    :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :contact_web, :presence => true
  validates :open_at, :timeliness => { :type => :datetime }
  validates :closed_at, :timeliness => { :type => :datetime, :after => :open_at }

  default_scope :order => 'fund_sources.name ASC'
  scope :closed, lambda { where( :closed_at.lt => Time.zone.now ) }
  scope :current, lambda {
    where( :open_at.lt => Time.zone.now, :closed_at.gt => Time.zone.now )
  }
  scope :open_deadline, lambda {
    current.joins { fund_queues }.
    where { fund_queues.submit_at.gt( Time.zone.now ) }
  }
  scope :open_deadline_for_first, lambda {
    open_deadline.joins { fund_queues.fund_request_types }.
    where { fund_queues.fund_request_types.allowed_for_first == true }
  }
  scope :upcoming, lambda { where( 'open_at > ?', Time.zone.now ) }
  scope :no_fund_grant_for, lambda { |organization|
    where { id.not_in( FundGrant.unscoped.
      where { organization_id.eq( my { organization.id } ) }.
      select { fund_source_id }
    ) }
  }
  scope :fulfilled_for, lambda { |perspective, *subjects|
    FundSource.joins { framework }.
    merge( Framework.unscoped.fulfilled_for( perspective, subjects ) )
  }
  scope :unfulfilled_for, lambda { |perspective, *subjects|
    FundSource.joins { framework }.
    merge( Framework.unscoped.unfulfilled_for( perspective, subjects ) )
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

