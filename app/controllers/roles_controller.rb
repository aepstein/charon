class RolesController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_role_from_params, :only => [ :new, :create ]
  filter_access_to :show, :new, :create, :update, :edit, :update, :destroy, :attribute_check => true

  # GET /roles
  # GET /roles.xml
  def index
    @roles = @roles.paginate( :page => params[:page] )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @roles }
    end
  end

  # GET /roles/:id
  # GET /roles/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/:id/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # POST /roles
  # POST /roles.xml
  def create
    respond_to do |format|
      if @role.save
        flash[:notice] = 'Role was successfully created.'
        format.html { redirect_to(@role) }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /roles/:id
  # PUT /roles/:id.xml
  def update
    respond_to do |format|
      if @role.update_attributes(params[:role])
        flash[:notice] = 'Role was successfully updated.'
        format.html { redirect_to(@role) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/:id
  # DELETE /roles/:id.xml
  def destroy
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @role = Role.find params[:id] if params[:id]
  end

  def initialize_index
    @roles = Role
  end

  def new_role_from_params
    @role = Role.new( params[:role] )
  end

end

