class RolesController < ApplicationController

  # GET /roles
  # GET /roles.xml
  def index
    @roles = Role.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @roles }
    end
  end

  # GET /roles/:id
  # GET /roles/:id.xml
  def show
    @role = Role.find(params[:id])
    raise AuthorizationError unless @role.may_see? current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = Role.new
    raise AuthorizationError unless @role.may_create? current_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/:id/edit
  def edit
    @role = Role.find(params[:id])
    raise AuthorizationError unless @role.may_update? current_user
  end

  # POST /roles
  # POST /roles.xml
  def create
    @role = Role.new(params[:role])
    raise AuthorizationError unless @role.may_create? current_user

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
    @role = Role.find(params[:id])
    raise AuthorizationError unless @role.may_update? current_user

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
    @role = Role.find(params[:id])
    raise AuthorizationError unless @role.may_destroy? current_user
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml  { head :ok }
    end
  end
end

