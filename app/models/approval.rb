class Approval < ActiveRecord::Base
  attr_accessible :as_of
  attr_readonly :user_id, :approvable_id, :approvable_type

  attr_accessor :as_of

  has_paper_trail class_name: 'SecureVersion'

  belongs_to :approvable, polymorphic: true
  belongs_to :user, inverse_of: :approvals

  scope :ordered, joins { user }.
    order { [ users.last_name, users.first_name, users.middle_name ] }
  scope :agreements, where( approvable_type: 'Agreement' )
  scope :fund_requests, where( approvable_type: 'FundRequest' )
  scope :with_approvable, lambda { |approvable|
    where { |a|
      a.approvable_type.eq( approvable.class.to_s ) &
      a.approvable_id.eq( approvable.id )
    }
  }
  scope :at_or_after, lambda { |time| where { |a| a.created_at.gte( time ) } }

  validates :as_of, on: :create, presence: true,
    numericality: { greater_than: 0, only_integer: 0 }
  validates :approvable_id, uniqueness: { scope: [ :approvable_type, :user_id ] }
  validates :approvable, presence: true
  validates :user, presence: true
  validate :approvable_must_not_change
  validate do
    if approvable.class == FundRequest
      if approvable.state_name == :started
        unless approvable.can_approve?
          errors.add( :approvable, ' is not in an approvable state' )
        end
        unless approvable.fund_editions.nonzero?
          approvable.errors.add( :base, ' must have at least one non-zero item' )
        end
      elsif ( approvable.review_state_name == :unreviewed &&
        [ :submitted, :released ].include?( approvable.state_name ) )
        unless approvable.can_approve_review?
          errors.add( :approvable, ' is not in an approvable state' )
          approvable.errors.add( :base, ' reviewer edition must accompany every item' )
        end
      end
    end
  end

  after_create :approve_approvable, :deliver_approval_notice, :update_frameworks
  after_destroy :unapprove_approvable, :deliver_unapproval_notice, :update_frameworks

  def to_s; "Approval of #{user} for #{fund_request}"; end

  protected

  def approvable_must_not_change
    return unless approvable && as_of && as_of.to_i
    if approvable.updated_at.to_i > as_of.to_i
      errors.add :base,
        "#{approvable} has changed since you saw it.  Please review again and confirm approval."
    end
  end

  def deliver_approval_notice
    ApprovalMailer.approval_notice( self ).deliver
  end

  def deliver_unapproval_notice
    ApprovalMailer.unapproval_notice( self ).deliver
  end

  def approve_approvable
    return true unless approvable.class == FundRequest
    if approvable.can_approve?
      approvable.approve
    else
      approvable.approve_review
    end
  end

  def unapprove_approvable
    return true unless approvable.class == FundRequest
    if approvable.can_unapprove?
      approvable.unapprove
    else
      approvable.unapprove_review
    end
  end

  def update_frameworks
    unless approvable_type != 'Agreement' || Framework.skip_update_frameworks
      user.update_frameworks
    end
    true
  end

end

