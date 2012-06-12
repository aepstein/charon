class Framework < ActiveRecord::Base
  cattr_accessor :skip_update_frameworks
  attr_accessible :name, :requirements_attributes

  has_many :approvers, inverse_of: :framework
  has_many :requirements, inverse_of: :framework
  has_many :fund_sources, inverse_of: :framework
  has_many :requirement_roles, through: :requirements, source: :role,
    uniq: true
  has_and_belongs_to_many :memberships do
    def update!
      proxy_association.send :memberships=, Membership.fulfill( proxy_association.owner )
    end
  end

  validates :name, presence: true, uniqueness: true

  accepts_nested_attributes_for :requirements,
    reject_if: proc { |attributes| attributes['fulfillable_name'].blank? },
    allow_destroy: true

  scope :ordered, order { name }
  # Find all fulfillables the membership fulfills
  scope :fulfilled_by, lambda { |membership|
    where { |f|
      f.id.not_in( Requirement.unfulfilled_by( membership ).select { framework_id } )
    }
  }

  after_save 'memberships.update!'

  def to_s; name; end

  def self.without_update_frameworks(&:block)
    old = skip_update_frameworks
    self.skip_update_frameworks = true
    yield
    self.skip_update_frameworks = old
  end

end

