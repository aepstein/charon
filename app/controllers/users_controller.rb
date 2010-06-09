class UsersController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_user_from_params, :only => [ :new, :create ]
  filter_access_to :show, :new, :create, :edit, :update, :destroy, :attribute_check => true

  def index
    @search = @users.with_permissions_to(:show).searchlogic( params[:search] )
    @users = @search.paginate( :page => params[:page] )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def create
    @user.admin = params[:user][:admin] if current_user.admin? && params[:user] && params[:user][:admin]

    respond_to do |format|
      if @user.save
        flash[:notice] = "User was successfully created."
        format.html { redirect_to @user }
        format.xml { head :ok }
      else
        format.html { render :action => :new }
        format.xml { render :xml => @user.errors.to_xml }
      end
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def profile
    # profile.html.erb
  end

  def edit
    # edit.html.erb
  end

  def update
    @user.admin = params[:user][:admin] if current_user.admin? && params[:user] && params[:user][:admin]

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to @user }
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
    @user.destroy

    respond_to do |format|
      flash[:notice] = 'User was successfully destroyed.'
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @user = User.find params[:id] if params[:id]
  end

  def initialize_index
    @users = User
  end

  def new_user_from_params
    @user = User.new( params[:user] )
  end
end

