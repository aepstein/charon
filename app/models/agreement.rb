class Agreement < ActiveRecord::Base
  include GlobalModelAuthorization

  named_scope :roles, lambda { |role|
    if role.class == Role
      roles = [role]
    else
      roles = role
    end
    role_ids = roles.map { |r| r.id }
    conditions = 'agreements.id IN (SELECT agreement_id FROM agreements_permissions INNER JOIN permissions ' +
                 'WHERE permissions.id = agreements_permissions.permission_id AND permissions.role_id IN (?) )'
    { :conditions =>  [conditions, role_ids] }
  }

  has_and_belongs_to_many :permissions
  has_many :approvals, :as => :approvable
  has_many :users, :through => :approvals

  validates_uniqueness_of :name
  validates_presence_of :name
  validates_presence_of :content
  validates_presence_of :contact_name
  validates_format_of :contact_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  def approve!
  end

  def unapprove!
  end

  def approvals_fulfilled?
    true
  end

  def may_approve?(user)
    true
  end

  def may_unapprove?(user)
    false
  end

  def may_unapprove_other?(user)
    false
  end

  def to_s
    name
  end
end

