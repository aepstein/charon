module FulfillableHelper

  def unfulfilled_requirement(fulfillable)
    case fulfillable.class.to_s
    when 'Agreement'
      "must approve #{h fulfillable}.  #{link_to 'Click here', new_agreement_approval_path(fulfillable)} to approve."
    when 'UserStatusCriterion'
      "must be one of #{fulfillable.statuses.join ', '}."
    when 'RegistrationCriterion'
      "must " + ( fulfillable.must_register? ? "be registered and " : "" ) +
      "have at least #{fulfillable.minimal_percentage}% #{fulfillable.type_of_member} in your registration. " +
      "#{link_to 'Click here', 'http://sao.cornell.edu'} to update your registration."
    else
      h(fulfillable.to_s)
    end
  end

end

