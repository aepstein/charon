class Role < ActiveRecord::Base
  MANAGER = %w( staff )
  REVIEWER = %w( member eboard commissioner )
  REQUESTOR =  %w( president vice-president treasurer officer advisor )

  attr_accessible :name

  default_scope :order => 'roles.name ASC'

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :memberships, :dependent => :destroy, :inverse_of => :role
  has_many :member_sources, :dependent => :destroy, :inverse_of => :role
  has_many :requirements, :dependent => :destroy, :inverse_of => :role
  has_many :approvers, :dependent => :destroy, :inverse_of => :role

  def to_s; name; end
end

