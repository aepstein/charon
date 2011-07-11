class Approver < ActiveRecord::Base
  attr_accessible :role_id, :state, :perspective, :quantity
  attr_readonly :framework_id

  belongs_to :framework, :inverse_of => :approvers
  belongs_to :role, :inverse_of => :approvers

  validates :framework, :presence => true
  validates :role, :presence => true
  validates :state,
    :inclusion => { :in => FundRequest.aasm_state_names.map(&:to_s) }
  validates :perspective,
    :inclusion => { :in => FundEdition::PERSPECTIVES }
  validates :role_id,
    :uniqueness => { :scope => [ :framework_id, :state, :perspective ] }

  default_scope includes( :role ).order( 'roles.name ASC' )

  scope :with_approvals_for, lambda { |fund_request|
    joins( "LEFT JOIN memberships ON approvers.role_id = memberships.role_id " +
      "AND memberships.active = #{connection.quote true} " +
      "AND ( (memberships.organization_id = #{fund_request.fund_grant.organization.id} AND approvers.perspective = 'requestor') OR " +
      "(memberships.organization_id = #{fund_request.fund_grant.fund_source.organization.id} AND approvers.perspective = 'reviewer') ) " +
      "LEFT JOIN approvals ON memberships.user_id = approvals.user_id AND " +
      "approvals.approvable_type = #{connection.quote 'FundRequest'} AND " +
      "approvals.approvable_id = #{fund_request.id} AND approvals.created_at > " +
      "#{connection.quote fund_request.approval_checkpoint}" ).
    group( 'approvers.id' ).
    where( 'approvers.framework_id = ? AND approvers.state = ?',
      fund_request.fund_grant.fund_source.framework_id, fund_request.state )
  }
  scope :satisfied, having('COUNT(approvals.user_id) >= approvers.quantity OR ' +
    '(approvers.quantity IS NULL AND COUNT(approvals.user_id) >= COUNT(memberships.user_id) )')
  scope :unsatisfied, having( '( COUNT(approvals.user_id) < approvers.quantity ) OR ' +
    '(approvers.quantity IS NULL AND COUNT(approvals.user_id) < COUNT(memberships.user_id) )' )
  scope :fulfilled_for, lambda { |fund_request| satisfied.with_approvals_for( fund_request ) }
  scope :unfulfilled_for, lambda { |fund_request| unsatisfied.with_approvals_for( fund_request ) }
end

