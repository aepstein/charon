class Role < ActiveRecord::Base
  PERMISSIONS = %w( request review manage )

  default_scope :order => 'roles.name ASC'

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :memberships, :dependent => :destroy

  def permissions
    Role::PERMISSIONS.reject { |permission| ((permissions_mask || 0) & 2**Role::PERMISSIONS.index(permission)).zero? }
  end

  def permissions=(values)
    self.permissions_mask = (permissions & Role::PERMISSIONS).map { |permission| 2**Role::PERMISSIONS.index(permission) }.sum
  end

  def to_s
    name
  end
end

