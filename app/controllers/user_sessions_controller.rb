class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_session }
    end
  end

  # GET /user_sessions/sso
  def sso
    if sso_net_id && ( user = User.find_by_net_id( sso_net_id ) )
      @user_session = UserSession.create( user, true )
      flash[:notice] = "Login successful!"
      redirect_back_or_default profile_url
    else
      @user_session = UserSession.new
      render :action => :new
    end
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if ( sso_net_id ? false : @user_session.save )
      flash[:notice] = "Login successful!"
      redirect_back_or_default profile_url
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end
end

