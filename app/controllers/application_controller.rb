# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery

  is_authenticator
  has_breadcrumbs

  protected

  def permission_denied
    flash[:error] = "You are not allowed to perform the requested action."
    if @fund_grant && @fund_grant.fund_source
      if (
        permitted_to?( :request_framework, @fund_grant ) ||
        permitted_to?( :review_framework, @fund_grant )
      )
      flash[:error] += " " + unfulfilled_requirements_for_fund_grant(@fund_grant, current_user)
      end
    end
    redirect_to profile_url
  end

  # Prepares a concise explanation of unfulfilled requirements pertinent to a
  # fund grant
  def unfulfilled_requirements_for_fund_grant(fund_grant, *users)
    fund_grant.unfulfilled_requirements_for( users ).inject([]) do |memo, (fulfiller, requirements)|
      memo << ( "#{fulfiller == current_user ? 'You' : fulfiller} " +
      requirements.map { |r| r.to_s :condition }.join(',') + '.' )
    end.join(' ')
  end

end

