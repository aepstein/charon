class UniversityAccountsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  filter_access_to :show, :attribute_check => true
  filter_access_to :index do
    permitted_to! :index
  end
  filter_access_to :activate, :do_activate do
    permitted_to! :activate
  end

  # GET /university_accounts/activate
  def activate
  end

  # PUT /university_accounts/do_activate
  def do_activate
    respond_to do |format|
      if params[:accounts].blank? || params[:activate].blank?
        hits = 0
      else
        hits = UniversityAccount.unscoped.where( "CONCAT( account_code, " +
          "subaccount_code ) IN (?)", CSV.parse(params[:accounts]).flatten
        ).update_all( [ "active = ?", ( params[:activate] == 'active' ? true : false ) ] )
      end
      flash[:notice] = ( ( params[:activate] == 'active' ? 'A' : 'Ina' ) +
       "ctivated #{hits} university account#{hits == 1 ? '' : 's'}." )
      format.html { redirect_to activate_university_accounts_url }
      format.xml { head :ok }
    end
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

end

