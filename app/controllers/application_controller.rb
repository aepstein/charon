class ApplicationController < ActionController::Base
  protect_from_forgery

  is_authenticator
  has_breadcrumbs

  protected

  def permission_denied
    alert = "You are not allowed to perform the requested action."
    if @fund_grant && @fund_grant.fund_source
      if (
        permitted_to?( :request_framework, @fund_grant ) ||
        permitted_to?( :review_framework, @fund_grant )
      )
      alert += " " + unfulfilled_requirements_for_fund_grant(
        @fund_grant, current_user, @fund_grant.organization )
      end
    end
    redirect_to profile_url, alert: alert
  end

  # Prepares a concise explanation of unfulfilled requirements pertinent to a
  # fund grant
  def unfulfilled_requirements_for_fund_grant(fund_grant, *fulfillers)
    fund_grant.unfulfilled_requirements_for( fulfillers ).inject([]) do |memo, (fulfiller, requirements)|
      fulfiller_str = case fulfiller
      when current_user
        'You'
      else
        fund_grant.organization.to_s
      end
      memo << ( fulfiller_str + " " + requirements.map { |r| r.to_s :condition }.join(',') + '.' )
    end.join(' ')
  end

  # Sets up matching organizations for approved, unmatched registrations of the current user
  # * should call any time the user might expect to do something with the unmatched organization
  # * should only call on approved registrations to limit possibility of duplicate
  #   organization instantiation
  def setup_matching_organizations
    current_user.registrations.current.registered.unmatched.readonly(false).each do |registration|
      registration.find_or_create_organization
    end
  end

end

