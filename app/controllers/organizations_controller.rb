class OrganizationsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index, :untiered ]
  before_filter :new_organization_from_params, :only => [ :new, :create ]
  before_filter :initialize_organization_profile, :only => [ :new, :edit ]
  filter_access_to :new, :create, :edit, :update, :destroy, :dashboard, :attribute_check => true

  # GET /organizations
  # GET /organizations.xml
  def index
    @search = params[:search] || Hash.new
    @search[:name_contains] = params[:term] if params[:term]
    @search.each do |k,v|
      if !v.blank? && Organization::SEARCHABLE.include?( k.to_sym )
        @organizations = @organizations.send k, v
      end
    end
    @organizations = @organizations.page(params[:page])


    respond_to do |format|
      format.html { render action: 'index' } # index.html.erb
      format.json { render json: @organizations.map { |o| { id: o.id, label: o.name, value: o.name(:last_first) } } }
      format.xml  { render :xml => @organizations }
    end
  end

  # GET /fund_sources/:fund_source_id/organizations/untiered
  def untiered
    @organizations = @organizations.where { |o|
      o.id.not_in( @fund_source.fund_tier_assignments.scoped.select { organization_id } )
    }
    return index
  end

  # GET /organizations/1
  # GET /organizations/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @organization }
    end
  end

  # GET /organizations/1/dashboard
  # GET /organizations/1/dashboard.xml
  def dashboard
    # dashboard.html.erb
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
        :as => ( permitted_to?( :admin, @organization ) ? :admin : :default ) )
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
    @fund_source = FundSource.find params[:fund_source_id] if params[:fund_source_id]
    add_breadcrumb 'Organizations', organizations_path
    add_breadcrumb "#{@registration.name} registration", url_for( @registration ) if @registration
  end

  def initialize_index
    @organizations = Organization.scoped.ordered
  end

  def initialize_organization_profile
    @organization.build_organization_profile if @organization.organization_profile.blank?
  end

  def new_organization_from_params
    @organization = @registration.find_or_build_organization( params[:organization], as: :admin ) if @registration
    @organization ||= Organization.new( params[:organization], as: :admin )
  end

end

