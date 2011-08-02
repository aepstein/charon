# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  attr_accessor :breadcrumbs

  protect_from_forgery
  helper_method :current_user_session, :current_user, :sso_net_id, :breadcrumbs
  before_filter :check_authorization

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

  # Prepares a concise explanation of unfulfilled requirements pertinent to a
  # fund grant
  def unfulfilled_requirements_for_fund_grant(fund_grant, *users)
    fund_grant.unfulfilled_requirements_for( users ).inject([]) do |memo, (fulfiller, requirements)|
      memo << ( "#{fulfiller == current_user ? 'You' : fulfiller} " +
      requirements.map { |r| r.to_s :condition }.join(',') + '.' )
    end.join(' ')
  end

  def check_authorization
    Authorization.current_user = current_user
  end

  # Obtains user record for currently logged in user
  # * if sso credential is detected verifies it matches session and
  #   updates/logs in automatically as needed
  def current_user
    return @current_user unless @current_user.blank?
    @current_user = User.find(session[:user_id]) if session[:user_id]
    if sso_net_id
      if @current_user && @current_user.net_id != sso_net_id
        @current_user = nil
        session[:user_id] = nil
      end
      return @current_user unless @current_user.blank?
      if @current_user = User.find_by_net_id( sso_net_id )
        session[:user_id] = @current_user.id
      end
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
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

end

