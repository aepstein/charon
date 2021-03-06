class Agreement < ActiveRecord::Base
  attr_accessible :name, :contact_name, :contact_email, :purpose, :content

  default_scope order { name }
  scope :fulfilled_by, lambda { |user|
    unless user.class.to_s == 'User'
      raise ArgumentError, "received #{user.class} instead of User"
    end
    where { |a| a.id.in( user.approved_agreements.scoped.select { id } ) }
  }

  has_many :approvals, as: :approvable, dependent: :delete_all
  has_many :users, through: :approvals

  has_paper_trail class_name: 'SecureVersion'

  validates :name, uniqueness: true, presence: true
  validates :content, presence: true
  validates :contact_name, presence: true
  validates :contact_email,
    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  after_update 'approvals.clear if content_changed?'
  is_fulfillable 'User'

  def to_s(format = nil)
    case format
    when :requirement
      "must approve the #{self}"
    else
      name
    end
  end

end

