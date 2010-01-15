class PermissionsController < ApplicationController
  before_filter :require_user

  # GET /framework/:framework_id/permissions
  # GET /framework/:framework_id/permissions.xml
  def index
    @framework = Framework.find(params[:framework_id])
    raise AuthorizationError unless @framework.may_see? current_user
    @permissions = @framework.permissions

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @permissions }
    end
  end

  # GET /permissions/1
  # GET /permissions/1.xml
  def show
    @permission = Permission.find(params[:id])
    raise AuthorizationError unless @permission.may_see? current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @permission }
    end
  end

  # GET /framework/:framework_id/permissions/new
  # GET /framework/:framework_id/permissions/new.xml
  def new
    @permission = Framework.find(params[:framework_id]).permissions.build
    raise AuthorizationError unless @permission.may_create? current_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @permission }
    end
  end

  # GET /permissions/1/edit
  def edit
    @permission = Permission.find(params[:id])
    raise AuthorizationError unless @permission.may_update? current_user
  end

  # POST /framework/:framework_id/permissions
  # POST /framework/:framework_id/permissions.xml
  def create
    @permission = Framework.find(params[:framework_id]).permissions.build(params[:permission])
    raise AuthorizationError unless @permission.may_create? current_user

    respond_to do |format|
      if @permission.save
        flash[:notice] = 'Permission was successfully created.'
        format.html { redirect_to(@permission) }
        format.xml  { render :xml => @permission, :status => :created, :location => @permission }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @permission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /permissions/1
  # PUT /permissions/1.xml
  def update
    @permission = Permission.find(params[:id])
    raise AuthorizationError unless @permission.may_update? current_user

    respond_to do |format|
      if @permission.update_attributes(params[:permission])
        flash[:notice] = 'Permission was successfully updated.'
        format.html { redirect_to(@permission) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @permission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /permissions/1
  # DELETE /permissions/1.xml
  def destroy
    @permission = Permission.find(params[:id])
    raise AuthorizationError unless @permission.may_destroy? current_user
    @permission.destroy

    respond_to do |format|
      format.html { redirect_to(framework_permissions_url(@permission.framework)) }
      format.xml  { head :ok }
    end
  end
end

