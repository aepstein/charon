class UsersController < ApplicationController

  before_filter :require_user

  def index
    page = params[:page] ? params[:page] : 1
    if params[:search]
      @users = User.first_name_or_middle_name_or_last_name_or_net_id_like("%#{params[:search][:q]}%").paginate(:page => page)
    else
      @users = User.paginate(:page => page)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  def new
   @user = User.new
   raise AuthorizationError unless @user.may_create?(current_user)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def create
    @user = User.new(params[:user])
    raise AuthorizationError unless @user.may_create?(current_user)
    @user.admin = params[:user][:admin] if current_user.admin? && params[:user][:admin]

    respond_to do |format|
      if @user.save
        flash[:notice] = "User was successfully created."
        format.html { redirect_to users_url }
        format.xml { head :ok }
      else
        format.html { render :action => :new }
        format.xml { render :xml => @user.errors.to_xml }
      end
    end
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def profile
    # profile.html.erb
  end

  def edit
    @user = User.find(params[:id])
    raise AuthorizationError unless @user.may_update?(current_user)
  end

  def update
    @user = User.find(params[:id])
    raise AuthorizationError unless @user.may_update?(current_user)
    @user.admin = params[:user][:admin] if current_user.admin? && params[:user][:admin]

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to users_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  # DELETE /users/:id
  # DELETE /users/:id.xml
  def destroy
    @user = User.find(params[:id])
    raise AuthorizationError unless @user.may_destroy?(current_user)
    @user.destroy

    respond_to do |format|
      flash[:notice] = 'User was successfully destroyed.'
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
end

