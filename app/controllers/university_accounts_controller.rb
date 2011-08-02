class UniversityAccountsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_university_account_from_params, :only => [ :new, :create ]
  filter_access_to :show, :new, :create, :update, :edit, :update, :destroy, :attribute_check => true
  filter_access_to :index do
    permitted_to! :index
  end

  # GET /university_accounts
  # GET /university_accounts.xml
  def index
#    @search = @university_accounts.with_permissions_to(:show).search( params[:search] )
    @q = @university_accounts.search( params[:q] )
    @university_accounts = @q.result.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @university_accounts }
    end
  end

  # GET /university_accounts/1
  # GET /university_accounts/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @university_account }
    end
  end

  # GET /university_accounts/new
  # GET /university_accounts/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @university_account }
    end
  end

  # GET /university_accounts/1/edit
  def edit
  end

  # POST /university_accounts
  # POST /university_accounts.xml
  def create
    respond_to do |format|
      if @university_account.save
        flash[:notice] = 'University account was successfully created.'
        format.html { redirect_to(@university_account) }
        format.xml  { render :xml => @university_account, :status => :created, :location => @university_account }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @university_account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /university_accounts/1
  # PUT /university_accounts/1.xml
  def update
    respond_to do |format|
      if @university_account.update_attributes(params[:university_account])
        flash[:notice] = 'University account was successfully updated.'
        format.html { redirect_to(@university_account) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @university_account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /university_accounts/1
  # DELETE /university_accounts/1.xml
  def destroy
    @university_account.destroy

    respond_to do |format|
      format.html { redirect_to university_accounts_url }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @university_account = UniversityAccount.find params[:id] if params[:id]
    @organization = Organization.find params[:organization_id] if params[:organization_id]
    @organization ||= @university_account.organization if @university_account
    @context = @organization if @organization
    add_breadcrumb 'University accounts', university_accounts_path
    if @organization
      add_breadcrumb 'Organizations', organizations_path
      add_breadcrumb @organization.name, url_for( @organization )
      add_breadcrumb 'University accounts', organization_university_accounts_path( @organization )
    end
  end

  def initialize_index
    @university_accounts = UniversityAccount.where( :organization_id => @organization.id ) if @organization
    @university_accounts ||= UniversityAccount.scoped
    @university_accounts = @university_accounts.with_permissions_to( :show )
  end

  def new_university_account_from_params
    @university_account = @organization.university_accounts.build( params[:university_account] )
  end

end

