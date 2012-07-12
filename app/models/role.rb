class Role < ActiveRecord::Base
  MANAGER = %w( staff )
  REVIEWER = %w( member eboard commissioner )
  REQUESTOR =  %w( president vice-president treasurer officer advisor )
  LEADER = %w( eboard )

  attr_accessible :name

  default_scope order { name }
  # Returns the roles a user has associated with an organization and perspective
  # * examines only active memberships
  scope :for_perspective, lambda { |perspective, organization, user|
    joins { memberships }.
    where {
      name.in( Role.names_for_perspective( my { perspective } ) ) &
      memberships.user_id.eq( my { user.id } ) &
      memberships.organization_id.eq( my { organization.id } ) &
      memberships.active.eq( true )
    }
  }
  scope :requestor, where { name.in( Role::REQUESTOR ) }
  scope :reviewer, where { name.in( Role::REVIEWER ) }
  scope :manager, where { name.in( Role::MANAGER ) }

  validates :name, presence: true, uniqueness: true

  has_many :memberships, dependent: :destroy, inverse_of: :role
  has_many :member_sources, dependent: :destroy, inverse_of: :role
  has_many :requirements, dependent: :destroy, inverse_of: :role
  has_many :approvers, dependent: :destroy, inverse_of: :role

  def self.names_for_perspective( perspective )
    case perspective.to_sym
    when :requestor
      REQUESTOR
    when :reviewer
      REVIEWER
    else
      Array.new
    end
  end

  def to_s; name; end
end

