class Agreement < ActiveRecord::Base
  include Fulfillable

  default_scope order( 'agreements.name ASC' )

  has_many :approvals, :as => :approvable, :dependent => :delete_all
  has_many :users, :through => :approvals
  has_many :fulfillments, :as => :fulfillable, :dependent => :delete_all

  validates_uniqueness_of :name
  validates_presence_of :name
  validates_presence_of :content
  validates_presence_of :contact_name
  validates_format_of :contact_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

#  after_update :destroy_approvals_if_content_changes
  after_save :fulfill
  after_update :unfulfill

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

  def to_s; name; end

end

