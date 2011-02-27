class Role < ActiveRecord::Base
  MANAGER = %w( staff )
  REVIEWER = %w( member eboard commissioner )
  REQUESTOR =  %w( president vice-president treasurer officer advisor )

  default_scope :order => 'roles.name ASC'

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :memberships, :dependent => :destroy
  has_many :member_sources, :dependent => :destroy

  def to_s; name; end
end

