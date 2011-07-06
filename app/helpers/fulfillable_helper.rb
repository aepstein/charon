module FulfillableHelper

  def unfulfilled_requirement(fulfillable, context)
    case fulfillable.class.to_s
    when 'Agreement'
      "must approve #{h fulfillable} #{requirement_context(fulfillable, context)}.  #{link_to 'Click here', new_agreement_approval_path(fulfillable)} to approve."
    when 'UserStatusCriterion'
      "must be one of #{fulfillable.statuses.join ', '} #{requirement_context(fulfillable, context)}."
    when 'RegistrationCriterion'
      "must " + ( fulfillable.must_register? ? "be registered and " : "" ) +
      "have at least #{fulfillable.minimal_percentage}% #{fulfillable.type_of_member} as members in the registration #{requirement_context(fulfillable, context)}. " +
      "#{link_to 'Click here', 'http://sao.cornell.edu'} to update the registration."
    else
      h(fulfillable.to_s)
    end
  end

  def requirement_context(requirement, context)
    contexts = context.permissions.requirements_fulfillable_type_equals(requirement.class.to_s).requirements_fulfillable_id_equals(requirement.id).all(:include => :framework).inject({}) do |memo, permission|
      memo[permission.framework] ||= []
      memo[permission.framework] << permission.action unless memo[permission.framework].include? permission.action
      memo
    end
    context_statements = []
    contexts.each do |framework, actions|
      context_statements << "#{actions.join ', '} #{framework} fund_requests"
    end
    "in order to #{context_statements.join ', '}"
  end
end

