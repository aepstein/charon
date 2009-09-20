class AuthorizationError < StandardError
end

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_user_session, :current_user
  helper_method :approvable_approval_path, :new_approvable_approval_path
  filter_parameter_logging :password, :password_confirmation

protected

  def rescue_action(e)
    case e
    when AuthorizationError
#      head :forbidden
      respond_to do |format|
        format.html { redirect_to( unauthorized_path ) }
      end
    else
      super(e)
    end
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session.record if current_user_session && current_user_session.record
  end

  def require_user
    if current_user && request.env['HTTP_REMOTE_USER'] && (current_user.net_id != request.env['HTTP_REMOTE_USER'])
      current_user_session.destroy
      return redirect_to_login
    end
    unless current_user
      return redirect_to_login
    end
  end

  def redirect_to_login
    store_location
    flash[:notice] = "You must be logged in to access this page"
    redirect_to login_url
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

  def approvable_approval_path(approvable)
    case approvable.class.to_s
    when "Agreement"
      agreement_approval_path(approvable)
    when "Request"
      request_approval_path(approvable)
    else
      raise "Class #{approvable.class} not supported."
    end
  end

  def new_approvable_approval_path(approvable)
    case approvable.class.to_s
    when "Agreement"
      new_agreement_approval_path(approvable)
    when "Request"
      new_request_approval_path(approvable)
    else
      raise "Class #{approvable.class} not supported."
    end
  end
end

