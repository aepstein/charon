class OrganizationsController < ApplicationController
  before_filter :require_user

  # GET /organizations
  # GET /organizations.xml
  def index
    page = params[:page] ? params[:page] : 1
    if params[:search]
      @organizations = Organization.first_name_or_last_name_like("%#{params[:search][:q]}%").paginate(:page => page)
  else
      @organizations = Organization.paginate(:page => page)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @organizations }
    end
  end

  # GET /organizations/1
  # GET /organizations/1.xml
  def show
    @organization = Organization.find(params[:id])
    raise AuthorizationError unless @organization.may_see? current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @organization }
    end
  end

  # GET /organizations/1/profile
  # GET /organizations/1/profile.xml
  def profile
    @organization = Organization.find(params[:id])
    raise AuthorizationError unless @organization.may_see?(current_user)

    respond_to do |format|
      format.html # profile.html.erb
      format.xml  { render :xml => @organization }
    end
  end

  # GET /organizations/new
  # GET /organizations/new.xml
  # GET /registrations/:registration_id/organizations/new
  # GET /registrations/:registration_id/organizations/new.xml
  def new
    if params[:registration_id]
      @registration = Registration.find(params[:registration_id])
      @organization = @registration.find_or_build_organization
    else
      @organization = Organization.new
    end
    raise AuthorizationError unless @organization.may_create? current_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @organization }
    end
  end

  # GET /organizations/1/edit
  def edit
    @organization = Organization.find(params[:id])
    raise AuthorizationError unless @organization.may_update? current_user
  end

  # POST /organizations
  # POST /organizations.xml
  # POST /registrations/:registration_id/organization
  # POST /registrations/:registration_id/organization.xml
  def create
    if params[:registration_id]
      @registration = Registration.find(params[:registration_id])
      @organization = @registration.find_or_build_organization(params[:organization])
      raise 'Cannot create an organization for a registration that is matched to an existing organization' unless @organization.new_record?
    else
      @organization = Organization.new(params[:organization])
    end
    raise AuthorizationError unless @organization.may_create? current_user

    respond_to do |format|
      if @organization.save
        @organization.registrations << @registration if @registration
        flash[:notice] = 'Organization was successfully created.'
        format.html { redirect_to(@organization) }
        format.xml  { render :xml => @organization, :status => :created, :location => @organization }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @organization.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /organizations/1
  # PUT /organizations/1.xml
  def update
    @organization = Organization.find(params[:id])
    raise AuthorizationError unless @organization.may_update? current_user

    respond_to do |format|
      if @organization.update_attributes(params[:organization])
        flash[:notice] = 'Organization was successfully updated.'
        format.html { redirect_to(@organization) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @organization.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.xml
  def destroy
    @organization = Organization.find(params[:id])
    raise AuthorizationError unless @organization.may_destroy? current_user
    @organization.destroy

    respond_to do |format|
      format.html { redirect_to(organizations_url) }
      format.xml  { head :ok }
    end
  end
end

