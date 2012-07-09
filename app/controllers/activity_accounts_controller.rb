class ActivityAccountsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index, :past, :current, :future ]
  before_filter :new_activity_account_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, attribute_check: true
  filter_access_to :index do
    permitted_to!( :show, @context ) if @context
    true
  end

  # GET /activity_accounts
  # GET /activity_accounts.xml
  def index
    @search = @activity_accounts.search( params[:search] )
    @activity_accounts = @search.result.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activity_accounts }
    end
  end

  # GET /activity_accounts/1
  # GET /activity_accounts/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @activity_account }
    end
  end

  # GET /activity_accounts/new
  # GET /activity_accounts/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity_account }
    end
  end

  # GET /activity_accounts/1/edit
  def edit; end

  # POST /activity_accounts
  # POST /activity_accounts.xml
  def create
    respond_to do |format|
      if @activity_account.save
        format.html { redirect_to(@activity_account, :notice => 'Activity account was successfully created.') }
        format.xml  { render :xml => @activity_account, :status => :created, :location => @activity_account }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity_account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /activity_accounts/1
  # PUT /activity_accounts/1.xml
  def update
    respond_to do |format|
      if @activity_account.update_attributes(params[:activity_account])
        format.html { redirect_to(@activity_account, :notice => 'Activity account was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity_account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /activity_accounts/1
  # DELETE /activity_accounts/1.xml
  def destroy
    @activity_account.destroy

    respond_to do |format|
      format.html { redirect_to fund_grant_activity_accounts_url( @activity_account.fund_grant ) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @activity_account = ActivityAccount.find( params[:id] ) if params[:id]
    @fund_grant = FundGrant.find( params[ :fund_grant_id ] ) if params[:fund_grant_id]
    @organization = Organization.find( params[:organization_id] ) if params[:organization_id]
    @context = @fund_grant || @organization
    add_breadcrumb @organization.name, organization_path( @organization ) if @organization
    add_breadcrumb @fund_grant, fund_grant_path( @fund_grant ) if @fund_grant
  end

  def initialize_index
    @activity_accounts = ActivityAccount.scoped
    @activity_accounts = @activity_accounts.organization_id_equals( @organization.id ) if @organization
    @activity_accounts = @activity_accounts.where(
      fund_grant_id: @fund_grant.id ) if @fund_grant
    @activity_accounts = @activity_accounts.with_permissions_to(:show)
  end

  def new_activity_account_from_params
    @activity_account = @fund_grant.activity_accounts.build( params[:activity_account] )
  end

end

