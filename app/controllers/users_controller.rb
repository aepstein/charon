class UsersController < ApplicationController

  def index
    @users = User.all
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
    @organizations = current_user.memberships.map { |m| m.organization }.uniq
    @organizations = @organizations.reject { |o| o.nil? }
    @unmatched_registrations = current_user.registrations.unmatched.uniq
  end

  def edit
    @user = User.find(params[:id])
    raise AuthorizationError unless @user.may_update?(current_user)
  end

  def update
    @user = User.find(params[:id])
    raise AuthorizationError unless current_user.may_update?(@user)
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

