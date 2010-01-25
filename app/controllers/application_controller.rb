class AuthorizationError < StandardError
end

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_user_session, :current_user, :sso_net_id
  filter_parameter_logging :password, :password_confirmation

protected

  def rescue_action(e)
    case e
    when AuthorizationError
#      head :forbidden
      respond_to do |format|
        format.html do
          flash[:error] = "Unauthorized request: You are not allowed to perform the requested action."
          redirect_to profile_path
        end
      end
    else
      super(e)
    end
  end

  def sso_net_id
    return false unless request.env['REMOTE_USER'] && !request.env['REMOTE_USER'].blank?
    request.env['REMOTE_USER']
  end

  private
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
    redirect_to_login unless current_user
  end

  def redirect_to_login
    store_location
    if sso_net_id
      redirect_to sso_login_url
    else
      flash[:notice] = "You must be logged in to access this page"
      redirect_to login_url
    end
    return false
  end

  def require_no_user
    if current_user
      redirect_to profile_url
      return false
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

