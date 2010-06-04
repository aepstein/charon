class Role < ActiveRecord::Base
  PERMISSIONS = %w( request review manage )

  default_scope :order => 'roles.name ASC'

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :memberships, :dependent => :destroy

  def permissions
    PERMISSIONS.reject { |permission| ((permissions_mask || 0) & 2**PERMISSIONS.index(permission)).zero? }
  end

  def permissions=(values)
    self.permissions_mask=( (values & PERMISSIONS).map { |permission| 2**PERMISSIONS.index(permission) }.sum )
  end

  def to_s
    name
  end
end

