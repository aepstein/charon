class FundGrantsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_fund_grant_from_params, :only => [ :new, :create ]
  before_filter :setup_breadcrumbs
  filter_access_to :new, :create, :edit, :update, :destroy, :show,
    :attribute_check => true
  filter_access_to :index do
    permitted_to!( :show, @organization ) if @organization
    permitted_to!( :show, @fund_source ) if @fund_source
    permitted_to!( :index )
  end

  # GET /organizations/:organization_id/fund_grants
  # GET /organizations/:organization_id/fund_grants.xml
  def index
    @search = @fund_grants.search( params[:search] )
    @fund_grants = @search.paginate( :page => params[:page], :per_page => 10, :include => {
      :approvals => [], :fund_source =>  { :organization => [:memberships], :framework => [] }
    } )

    respond_to do |format|
      format.html { render :action => 'index' }
      format.csv { csv_index }
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
      @fund_grant.valid?
      if @fund_grant.save
        @fund_grant.fund_requests.create!
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
      if @fund_grant.update_attributes(params[:fund_grant])
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
      flash[:notice] = 'FundGrant was successfully destroyed.'
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
    @fund_grants = @fund_grants.scoped( :conditions => { :organization_id => @organization.id } ) if @organization
    @fund_grants = @fund_grants.scoped( :conditions => { :fund_source_id => @fund_source.id }) if @fund_source
    @fund_grants = @fund_grants.with_permissions_to(:show)
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

  def csv_index
    csv_string = ""
    CSV.generate(csv_string) do |csv|
      csv << ( ['organizations', 'independent?','club sport?','state','allocation'] + Category.all.map { |c| "#{c.name} allocation" } )
      @search.each do |fund_grant|
        next unless permitted_to?( :review, fund_grant )
        csv << ( [ fund_grant.fund_grant.organization.name,
                   ( fund_grant.fund_grant.organization.independent? ? 'Yes' : 'No' ),
                   ( fund_grant.fund_grant.organization.club_sport? ? 'Yes' : 'No' ),
                   fund_grant.state,
                   "#{fund_grant.fund_items.sum('fund_items.amount')}" ] + Category.all.map { |c| "#{fund_grant.fund_items.allocation_for_category(c)}" } )
      end
    end
    send_data csv_string, :disposition => "attachment; filename=fund_grants.csv", :type => 'text/csv'
  end

end

