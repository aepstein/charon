class Role < ActiveRecord::Base
  MANAGER = %w( staff )
  REVIEWER = %w( member eboard commissioner )
  REQUESTOR =  %w( president vice-president treasurer officer advisor )

  attr_accessible :name

  default_scope :order => 'roles.name ASC'

  validates :name, :presence => true, :uniqueness => true

  has_many :memberships, :dependent => :destroy, :inverse_of => :role
  has_many :member_sources, :dependent => :destroy, :inverse_of => :role
  has_many :requirements, :dependent => :destroy, :inverse_of => :role
  has_many :approvers, :dependent => :destroy, :inverse_of => :role

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

