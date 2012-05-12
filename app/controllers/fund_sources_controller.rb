class FundSourcesController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_fund_source_from_params, :only => [ :new, :create ]
  before_filter :populate_fund_queues, :only => [ :new, :edit ]
  filter_access_to :show, :edit, :update, :new, :create, :destroy, :attribute_check => true
  filter_access_to :index do
    permitted_to!( :show, @organization )
  end

  # GET /organizations/:organization_id/fund_sources
  # GET /organizations/:organization_id/fund_sources.xml
  def index
    @q = @fund_sources.search( params[:q] )
    @fund_sources = @q.result.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fund_sources }
    end
  end

  # GET /fund_sources/1
  # GET /fund_sources/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fund_source }
    end
  end

  # GET /organizations/:organization_id/fund_sources/new
  # GET /organizations/:organization_id/fund_sources/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @fund_source }
    end
  end

  # GET /fund_sources/:id/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # POST /organizations/:organization_id/fund_sources
  # POST /organizations/:organization_id/fund_sources.xml
  def create
    respond_to do |format|
      if @fund_source.save
        flash[:notice] = 'Fund source was successfully created.'
        format.html { redirect_to(@fund_source) }
        format.xml  { render :xml => @fund_source, :status => :created, :location => @fund_source }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fund_source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /fund_sources/1
  # PUT /fund_sources/1.xml
  def update
    respond_to do |format|
      if @fund_source.update_attributes(params[:fund_source])
        flash[:notice] = 'Fund source was successfully updated.'
        format.html { redirect_to(@fund_source) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fund_source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /fund_sources/1
  # DELETE /fund_sources/1.xml
  def destroy
    @fund_source.destroy

    respond_to do |format|
      flash[:notice] = 'FundSource was successfully destroyed.'
      format.html { redirect_to(organization_fund_sources_url(@fund_source.organization)) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @fund_source = FundSource.find params[:id] if params[:id]
    @organization = Organization.find params[:organization_id] if params[:organization_id]
    @organization ||= @fund_source.organization if @fund_source
    if @organization
      add_breadcrumb @organization.name, organization_path( @organization )
      add_breadcrumb 'FundSources', organization_fund_sources_path( @organization )
    end
  end

  def initialize_index
    @fund_sources = @organization.fund_sources.with_permissions_to(:show)
    @fund_sources ||= FundSource.with_permissions_to(:show)
  end

  def new_fund_source_from_params
    @fund_source = @organization.fund_sources.build( params[:fund_source] )
  end

  def populate_fund_queues
    @fund_source.fund_queues.build
  end
end

