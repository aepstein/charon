# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  attr_accessor :breadcrumbs

  protect_from_forgery
  helper_method :current_user_session, :current_user, :sso_net_id, :breadcrumbs
  before_filter :check_authorization

  def permission_denied
    flash[:error] = "You are not allowed to perform the requested action."
    if @fund_request
      flash[:error] += " " + unfulfilled_requirements_for_fund_request(@fund_request)
    end
    redirect_to profile_url
  end

  def sso_net_id
    net_id = request.env['REMOTE_USER'] || request.env['HTTP_REMOTE_USER']
    net_id.blank? ? false : net_id
  end

  protected

  def add_breadcrumb name, url = ''
    self.breadcrumbs ||= []
    url = eval(url) if url =~ /_path|_url|@/
    self.breadcrumbs << [name, url]
  end

  def self.add_breadcrumb name, url, options = {}
    before_filter options do |controller|
      controller.send(:add_breadcrumb, name, url)
    end
  end

  private

  def unfulfilled_requirements_for_fund_request(fund_request)
    perspective = fund_request.perspective_for current_user
    perspective ||= FundEdition::PERSPECTIVES.first
    for_user = fund_request.unfulfilled_requirements_for current_user
    out = ""
    unless for_user.length == 0
      out << "You must fulfill the following requirements: #{for_user.join '; '}."
    end
    organization = fund_request.send(perspective)
    for_organization = fund_request.unfulfilled_requirements_for organization
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
    return @current_user if defined? @current_user
    @current_user = current_user_session && current_user_session.record
    # Delete stale session if sso_net_id has changed
    if sso_net_id && (@current_user.nil? || @current_user.net_id != sso_net_id)
      current_user_session.destroy
      @current_user_session = nil
      @current_user = nil
    end
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
    return if self.class == UserSessionsController
    session[:return_to] = fund_request.fund_request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

end

