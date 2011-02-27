# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user_session, :current_user, :sso_net_id
  before_filter :check_authorization

  def permission_denied
    flash[:error] = "You are not allowed to perform the requested action."
    if @request
      flash[:error] += " " + unfulfilled_requirements_for_request(@request)
    end
    redirect_to profile_url
  end

  def sso_net_id
    net_id = request.env['REMOTE_USER'] || request.env['HTTP_REMOTE_USER']
    net_id.blank? ? false : net_id
  end

  private

  def unfulfilled_requirements_for_request(request)
    perspective = request.perspective_for current_user
    perspective ||= Edition::PERSPECTIVES.first
    for_user = request.unfulfilled_requirements_for current_user
    out = ""
    unless for_user.length == 0
      out << "You must fulfill the following requirements: #{for_user.join '; '}."
    end
    organization = request.send(perspective)
    for_organization = request.unfulfilled_requirements_for organization
    unless for_organization.length == 0
      out << "#{organization} must fulfill the following requirements: #{for_organization.join '; '}."
    end
    out
  end

  def check_authorization
    Authorization.current_user = current_user
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    @current_user = current_user_session && current_user_session.record
    return nil if sso_net_id && (@current_user.nil? || @current_user.net_id != sso_net_id)
    @current_user
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = 'You must log in to access this page.'
      redirect_to login_url
    end
  end

  def require_no_user
    if current_user || @current_user
      redirect_to logout_url
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

end

