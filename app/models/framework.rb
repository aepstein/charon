class Framework < ActiveRecord::Base
  cattr_writer :skip_update_frameworks
  attr_accessible :name, :requirements_attributes, :approvers_attributes

  has_many :approvers, inverse_of: :framework
  has_many :requirements, inverse_of: :framework
  has_many :fund_sources, inverse_of: :framework
  has_many :submission_fund_sources, inverse_of: :submission_framework,
    class_name: 'FundSource', foreign_key: :submission_framework_id
  has_many :requirement_roles, through: :requirements, source: :role,
    uniq: true
  has_and_belongs_to_many :memberships

  has_many :users, through: :memberships
  has_many :organizations, through: :memberships

  validates :name, presence: true, uniqueness: true

  accepts_nested_attributes_for :requirements, allow_destroy: true
  accepts_nested_attributes_for :approvers, allow_destroy: true

  scope :ordered, order { name }
  # Find all fulfillables the membership fulfills
  scope :fulfilled_by, lambda { |membership|
    where { |f|
      f.id.not_in( Requirement.unfulfilled_by( membership ).select { framework_id } )
    }
  }
  scope :fulfilled_for_memberships, lambda { |memberships_scope|
    Framework.joins { memberships }.where { |f| f.memberships.id.in(
      memberships_scope.scoped.select { id } ) }.uniq
  }
  scope :unfulfilled_for_memberships, lambda { |memberships_scope|
    Framework.where { |f| f.id.not_in( memberships_scope.
      joins { frameworks }.select { frameworks.id } ) }.uniq
  }

  after_save :update_memberships

  def update_memberships
    self.membership_ids = Membership.active.fulfill( self ).value_of(:id)
  end

  def to_s; name; end

  # Disables update_frameworks for memberships within block
  # * this is useful for bulk operations where frameworks can be updated
  #   in a single action at the end
  def self.skip_update_frameworks(&block)
    return @@skip_update_frameworks if block.blank?
    old = skip_update_frameworks
    self.skip_update_frameworks = true
    result = yield
    self.skip_update_frameworks = old
    result
  end

end

