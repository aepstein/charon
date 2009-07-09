class OrganizationsController < ApplicationController
  # GET /organizations
  # GET /organizations.xml
  def index
    @organizations = Organization.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @organizations }
    end
  end

  # GET /organizations/1
  # GET /organizations/1.xml
  def show
    @organization = Organization.find(params[:id])
    eligible_requests = []
    Basis.open.each do |basis|
      @request = Basis.requests.build
      @request.organizations << @organization
      eligible_requests << @request
    end

    started_requests = @organization.requests

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @organization }
    end
  end

  # GET /organizations/1/profile
  # GET /organizations/1/profile.xml
  def profile
    @organization = Organization.find(params[:id])

    respond_to do |format|
      format.html # profile.html.erb
      format.xml  { render :xml => @organization }
    end
  end

  # GET /organizations/new
  # GET /organizations/new.xml
  def new
    @organization = Organization.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @organization }
    end
  end

  # GET /organizations/1/edit
  def edit
    @organization = Organization.find(params[:id])
  end

  # POST /organizations
  # POST /organizations.xml
  def create
    @organization = Organization.new(params[:organization])

    respond_to do |format|
      if @organization.save
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
    @organization.destroy

    respond_to do |format|
      format.html { redirect_to(organizations_url) }
      format.xml  { head :ok }
    end
  end
end

