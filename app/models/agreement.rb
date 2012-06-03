class Agreement < ActiveRecord::Base
  attr_accessible :name, :contact_name, :contact_email, :purpose, :content

  is_fulfillable

  default_scope order( 'agreements.name ASC' )
  scope :fulfilled_by, lambda { |user|
    where { |a| a.id.in( user.approved_agreements.scoped.select { id } ) }
  }

  has_many :approvals, as: :approvable, dependent: :delete_all
  has_many :users, through: :approvals

  has_paper_trail :class_name => 'SecureVersion'

  validates :name, :uniqueness => true, :presence => true
  validates :content, :presence => true
  validates :contact_name, :presence => true
  validates :contact_email,
    :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

#  after_update :destroy_approvals_if_content_changes

  def destroy_approvals_if_content_changes
    approvals.clear if content_changed?
  end

  def approve
    true
  end

  def unapprove
    true
  end

  def approvals_fulfilled?
    true
  end

  def to_s(format = nil)
    case format
    when :requirement
      "must approve the #{self}"
    else
      name
    end
  end

end

