class UsersController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_user_from_params, :only => [ :new, :create ]
  before_filter :add_blank_address, :only => [ :new, :edit ]
  filter_access_to :show, :new, :create, :edit, :update, :destroy, :attribute_check => true
  before_filter :setup_breadcrumbs, :except => [ :profile ]
  before_filter :setup_matching_organizations, only: [ :profile ]

  def index
    @search = params[:search] || Hash.new
    @search.each do |k,v|
      if !v.blank? && User::SEARCHABLE.include?( k.to_sym )
        @users = @users.send k, v
      end
    end
    @users = @users.page(params[:page])

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
    respond_to do |format|
      if @user.update_attributes(params[:user], @attr_role)
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
    @attr_role = { :as => ( current_user.admin? ? :admin : :default ) }
  end

  def initialize_index
    @users = User.with_permissions_to(:show)
  end

  def new_user_from_params
    @user = User.new(params[:user], @attr_role)
  end

  def setup_breadcrumbs
    add_breadcrumb 'Users', users_path
    if @user && @user.persisted?
      add_breadcrumb @user, user_path( @user )
    end
  end

  def add_blank_address
    @user.addresses.build
  end
end

