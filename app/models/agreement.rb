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
  has_many :approvals, :as => :approvable, :dependent => :destroy
  has_many :users, :through => :approvals
  has_many :fulfillments, :as => :fulfillable, :dependent => :delete_all

  validates_uniqueness_of :name
  validates_presence_of :name
  validates_presence_of :content
  validates_presence_of :contact_name
  validates_format_of :contact_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  after_update :destroy_approvals_if_content_changes
  after_create 'Fulfillment.fulfill self'
  after_update 'Fulfillment.unfulfill self', 'Fulfillment.fulfill self'

  def destroy_approvals_if_content_changes
    approvals.clear if content_changed?
  end

  def approve( approval )
    fulfillments.create( :fulfiller => approval.user )
    true
  end

  def unapprove( approval )
    fulfillments.delete fulfillments.fulfiller_id_eq( approval.user_id ).to_a
    true
  end

  def approvals_fulfilled?
    true
  end

  def may_approve?(user)
    return true if user
    false
  end

  def may_unapprove?(user)
    return true if user && user.admin?
    false
  end

  def may_unapprove_other?(user)
    return true if user && user.admin?
    false
  end

  def to_s
    name
  end
end

