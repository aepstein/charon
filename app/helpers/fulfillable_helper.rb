module FulfillableHelper

  def unfulfilled_permission(fulfillable, permission)
    out = ""
    permission.memberships.unfulfilled_for(fulfillable).all(:include => [ :user, :organization ]).each do |membership|
      out += "<li>" +
      "#{unfulfilled_membership_conjugation(membership,fulfillable)} #{fulfillable} in order for " +
      "#{membership.user == current_user ? 'you' : membership.user} " +
      "to #{permission.action} requests where #{membership.organization} is a " +
      "#{permission.perspective} (in the #{permission.framework} authorization framework)." +
      "</li>"
    end
    out
  end

  def unfulfilled_membership_conjugation(membership,fulfillable)
    return "You need" if current_user && membership.fulfiller_name(fulfillable) == current_user.name
    membership.fulfiller_name(fulfillable) + " needs"
  end

end

