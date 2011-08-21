class OrganizationsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_organization_from_params, :only => [ :new, :create ]
  before_filter :initialize_organization_profile, :only => [ :new, :edit ]
  filter_access_to :new, :create, :edit, :update, :destroy, :profile, :attribute_check => true

  # GET /organizations
  # GET /organizations.xml
  def index
    @search = params[:search] || Hash.new
    @search.each do |k,v|
      if !v.blank? && Organization::SEARCHABLE.include?( k.to_sym )
        @organizations = @organizations.send k, v
      end
    end
    @organizations = @organizations.page(params[:page])


    respond_to do |format|
      format.html # index.html.erb
      format.js # index.js.erb
      format.xml  { render :xml => @organizations }
    end
  end

  # GET /organizations/1
  # GET /organizations/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @organization }
    end
  end

  # GET /organizations/1/profile
  # GET /organizations/1/profile.xml
  def profile
    # profile.html.erb
  end

  # GET /organizations/new
  # GET /organizations/new.xml
  # GET /registrations/:registration_id/organizations/new
  # GET /registrations/:registration_id/organizations/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @organization }
    end
  end

  # GET /organizations/1/edit
  def edit
    # edit.html.erb
  end

  # POST /organizations
  # POST /organizations.xml
  # POST /registrations/:registration_id/organization
  # POST /registrations/:registration_id/organization.xml
  def create
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
    respond_to do |format|
      if @organization.update_attributes( params[:organization],
        :as => ( permitted_to?( :manage, @organization ) ? :admin : :default ) )
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
    @organization.destroy

    respond_to do |format|
      format.html { redirect_to(organizations_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @organization = Organization.find params[:id] if params[:id]
    @registration = Registration.find params[:registration_id] if params[:registration_id]
    add_breadcrumb 'Organizations', organizations_path
    add_breadcrumb "#{@registration.name} registration", url_for( @registration ) if @registration
  end

  def initialize_index
    @organizations = Organization.scoped
  end

  def initialize_organization_profile
    @organization.build_organization_profile if @organization.organization_profile.blank?
  end

  def new_organization_from_params
    @organization = @registration.find_or_build_organization( params[:organization], :as => :admin ) if @registration
    @organization ||= Organization.new( params[:organization], :as => :admin )
  end

end

