class Approval < ActiveRecord::Base
  attr_accessible :as_of
  attr_readonly :user_id, :approvable_id, :approvable_type

  has_paper_trail :class_name => 'SecureVersion'

  belongs_to :approvable, polymorphic: true
  belongs_to :user, inverse_of: :approvals

  scope :ordered, joins { user }.
    order { [ users.last_name, users.first_name, users.middle_name ] }
  scope :agreements, where( :approvable_type => 'Agreement' )
  scope :fund_requests, where( :approvable_type => 'FundRequest' )
  scope :at_or_after, lambda { |time| where { |a| a.created_at.gte( time ) } }

  validates :as_of, timeliness: { type: :datetime }
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

  after_create :approve_approvable, :deliver_approval_notice, :fulfill_user
  after_destroy :unapprove_approvable, :deliver_unapproval_notice, :unfulfill_user

  def as_of=(datetime)
    @as_of=datetime.to_s
  end

  def as_of
    return nil unless @as_of
    @as_of.to_datetime
  end

  def to_s; "Approval of #{user} for #{fund_request}"; end

  protected

  def approvable_must_not_change
    return unless approvable && as_of
    if approvable.updated_at.to_s.to_datetime > as_of
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

  def fulfill_user
    user.association(:approvals).reset
    user.fulfillments.fulfill! 'Agreement' if approvable_type == "Agreement"
  end

  def unfulfill_user
    user.association(:approvals).reset
    user.fulfillments.unfulfill! 'Agreement' if approvable_type == "Agreement"
  end
end

