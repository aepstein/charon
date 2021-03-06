class FundGrantsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index, :closed ]
  before_filter :new_fund_grant_from_params, :only => [ :new, :create ]
  before_filter :setup_breadcrumbs
  filter_access_to :new, :create, :edit, :update, :destroy, :show,
    attribute_check: true
  filter_access_to :index do
    permitted_to!( :show, @organization ) if @organization
    permitted_to!( :show, @fund_source ) if @fund_source
    permitted_to!( :index )
  end
  filter_access_to :released_report do
    permitted_to!( :review, @fund_source ) if @fund_source
  end

  # GET /fund_sources/:fund_source_id/fund_grants/released_report.csv
  def released_report
    respond_to do |format|
      format.csv do
        send_data @fund_source.fund_grants.released_report,
          filename: "fund_source_#{@fund_source.id}_released_report.csv",
          type: :csv, disposition: 'attachment'
      end
    end
  end

  def closed
    @fund_grants = @fund_grants.closed
    index
  end

  # GET /organizations/:organization_id/fund_grants
  # GET /organizations/:organization_id/fund_grants.xml
  def index
    @fund_grants_unpaginated = @fund_grants
    @search = params[:search] || Hash.new
    @search.each do |k,v|
      if !v.blank? && FundGrant::SEARCHABLE.include?( k.to_sym )
        @fund_grants_unpaginated = @fund_grants_unpaginated.send k, v
      end
    end
    @fund_grants = @fund_grants_unpaginated.page(params[:page])

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @fund_grants }
    end
  end

  # GET /fund_grants/1
  # GET /fund_grants/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fund_grant }
    end
  end

  # GET /organizations/:organization_id/fund_grants/new
  # GET /organizations/:organization_id/fund_grants/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @fund_grant }
    end
  end

  # POST /organizations/:organization_id/fund_grants
  # POST /organizations/:organization_id/fund_grants.xml
  def create
    respond_to do |format|
      @fund_grant.fund_requests.build_first
      if @fund_grant.save
        flash[:notice] = 'Fund grant was successfully created.'
        format.html { redirect_to @fund_grant.fund_requests.first }
        format.xml  { render :xml => @fund_grant, :status => :created, :location => @fund_grant }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fund_grant.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /fund_grants/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # PUT /fund_grants/1
  # PUT /fund_grants/1.xml
  def update
    respond_to do |format|
      if @fund_grant.update_attributes(params[:fund_grant], as: :reviewer)
        flash[:notice] = 'Fund grant was successfully updated.'
        format.html { redirect_to @fund_grant }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fund_grant.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /fund_grants/1
  # DELETE /fund_grants/1.xml
  def destroy
    @fund_grant.destroy

    respond_to do |format|
      flash[:notice] = 'Fund grant was successfully destroyed.'
      format.html { redirect_to( profile_url ) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @fund_grant = FundGrant.find params[:id] if params[:id]
    @fund_source = FundSource.find params[:fund_source_id] if params[:fund_source_id]
    @fund_source ||= @fund_grant.fund_source if @fund_grant
    @organization = Organization.find params[:organization_id] if params[:organization_id]
    @organization ||= @fund_grant.organization if @organization
    @context = @fund_source || @organization
  end

  def initialize_index
    @fund_grants = FundGrant.scoped
    @fund_grants = @organization.fund_grants if @organization
    @fund_grants = @fund_source.fund_grants if @fund_source
    @fund_grants = @fund_grants.includes { organization } unless @organization
    @fund_grants = @fund_grants.includes { fund_source } unless @fund_source
    @fund_grants = @fund_grants.ordered
#    @fund_grants = @fund_grants.with_permissions_to(:show)
  end

  def new_fund_grant_from_params
    @fund_grant = @organization.fund_grants.build( params[:fund_grant] )
  end

  def setup_breadcrumbs
    if @fund_source && permitted_to?( :review, @fund_grant )
      add_breadcrumb @fund_source.name, url_for( @fund_source )
      add_breadcrumb 'Fund grants', fund_source_fund_grants_path( @fund_source )
    end
    if @organization
      add_breadcrumb @organization.name, url_for( @organization )
      add_breadcrumb 'Fund grants', organization_fund_grants_path( @organization )
    end
  end

end

