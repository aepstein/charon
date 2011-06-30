class Agreement < ActiveRecord::Base
  include Fulfillable

  attr_accessible :name, :contact_name, :contact_email, :purpose, :content

  default_scope order( 'agreements.name ASC' )

  has_many :approvals, :as => :approvable, :dependent => :delete_all
  has_many :users, :through => :approvals
  has_many :fulfillments, :as => :fulfillable, :dependent => :delete_all

  has_paper_trail :class_name => 'SecureVersion'

  validates :name, :uniqueness => true, :presence => true
  validates :content, :presence => true
  validates :contact_name, :presence => true
  validates :contact_email,
    :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

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

