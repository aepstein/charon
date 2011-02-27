class Approver < ActiveRecord::Base
  belongs_to :framework
  belongs_to :role

  validates_presence_of :framework
  validates_presence_of :role
  validates_inclusion_of :status, :in => Request.aasm_state_names
  validates_inclusion_of :perspective, :in => Edition::PERSPECTIVES
  validates_uniqueness_of :role_id, :scope => [ :framework_id, :status, :perspective ]

  default_scope :include => [:role], :order => 'roles.name ASC'

  scope :with_approvals_for, lambda { |request|
    joins( "LEFT JOIN memberships ON approvers.role_id = memberships.role_id " +
      "AND memberships.active = #{connection.quote true} " +
      "AND ( (memberships.organization_id = #{request.organization.id} AND approvers.perspective = 'requestor') OR " +
      "(memberships.organization_id = #{request.basis.organization.id} AND approvers.perspective = 'reviewer') ) " +
      "LEFT JOIN approvals ON memberships.user_id = approvals.user_id AND " +
      "approvals.approvable_type = #{connection.quote 'Request'} AND " +
      "approvals.approvable_id = #{request.id} AND approvals.created_at > " +
      "#{connection.quote request.approval_checkpoint}" ).
    group( 'approvers.id' ).
    where( 'approvers.framework_id = ? AND approvers.status = ?',
      request.basis.framework_id, request.status )
  }
  scope :satisfied, having('COUNT(approvals.user_id) >= approvers.quantity OR ' +
    '(approvers.quantity IS NULL AND COUNT(approvals.user_id) >= COUNT(memberships.user_id) )')
  scope :unsatisfied, having( '( COUNT(approvals.user_id) < approvers.quantity ) OR ' +
    '(approvers.quantity IS NULL AND COUNT(approvals.user_id) < COUNT(memberships.user_id) )' )
  scope :fulfilled_for, lambda { |request| satisfied.with_approvals_for( request ) }
  scope :unfulfilled_for, lambda { |request| unsatisfied.with_approvals_for( request ) }
end

