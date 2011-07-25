class FundRequestsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index, :duplicate ]
  before_filter :new_fund_request_from_params, :only => [ :new, :create ]
  before_filter :setup_breadcrumbs
  filter_access_to :new, :create, :edit, :update, :reject, :do_reject, :destroy,
    :show, :accept, :attribute_check => true
  filter_access_to :documents_report do
    permitted_to! :show, @fund_request
  end
  filter_access_to :index, :duplicate do
    permitted_to!( :show, @organization ) if @organization
    permitted_to!( :show, @fund_source ) if @fund_source
    permitted_to!( :index )
  end

  # /fund_requests/:id/documents_report.pdf
  def documents_report
    respond_to do |format|
      format.pdf do
        send_data DocumentsReport.new( @fund_request ).to_pdf,
          :filename => 'documents_report.pdf', :type => :pdf,
          :disposition => 'inline'
      end
    end
  end

  # PUT /fund_requests/:id/withdraw
  def withdraw
    @fund_request.withdrawn_by_user = current_user
    @fund_request.withdraw!
    flash[:notice] = 'FundRequest was successfully withdrawn.'
    respond_to do |format|
      format.html { redirect_to :back }
      format.xml { head :ok }
    end
  end

  def accept
    @fund_request.accept!
    flash[:notice] = 'FundRequest was successfully accepted.'
    respond_to do |format|
      format.html { redirect_to :back }
      format.xml { head :ok }
     end
  end

  def reject; end

  def do_reject
    unless params[:fund_request].blank? || params[:fund_request][:reject_message].blank?
      @fund_request.update_attribute :reject_message, params[:fund_request][:reject_message]
      @fund_request.reject!
      flash[:notice] = 'FundRequest was successfully rejected.'
      respond_to do |format|
        format.html { redirect_to @fund_request }
        format.xml  { head :ok }
      end
    else
      @fund_request.errors.add :reject_message, "cannot be empty."
      respond_to do |format|
        format.html { render :action => "reject" }
        format.xml  { render :xml => @fund_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  def duplicate
    @fund_requests = @fund_requests.duplicate
    index
  end

  # GET /organizations/:organization_id/fund_requests
  # GET /organizations/:organization_id/fund_requests.xml
  def index
    @search = @fund_requests.search( params[:search] )
    @fund_requests = @search.paginate( :page => params[:page], :per_page => 10, :include => {
      :approvals => [], :fund_source =>  { :organization => [:memberships], :framework => [] }
    } )

    respond_to do |format|
      format.html { render :action => 'index' }
      format.csv { csv_index }
      format.xml  { render :xml => @fund_requests }
    end
  end

  # GET /fund_requests/1
  # GET /fund_requests/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fund_request }
    end
  end

  # GET /organizations/:organization_id/fund_requests/new
  # GET /organizations/:organization_id/fund_requests/new.xml
  # TODO -- should this action exist?
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @fund_request }
    end
  end

  # POST /organizations/:organization_id/fund_requests
  # POST /organizations/:organization_id/fund_requests.xml
  def create
    respond_to do |format|
      if @fund_request.save
        flash[:notice] = 'FundRequest was successfully created.'
        format.html { redirect_to @fund_request }
        format.xml  { render :xml => @fund_request, :status => :created, :location => @fund_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fund_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /fund_requests/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # PUT /fund_requests/1
  # PUT /fund_requests/1.xml
  def update
    respond_to do |format|
      if @fund_request.update_attributes(params[:fund_request])
        flash[:notice] = 'FundRequest was successfully updated.'
        format.html { redirect_to @fund_request }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fund_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /fund_requests/1
  # DELETE /fund_requests/1.xml
  def destroy
    @fund_request.destroy

    respond_to do |format|
      flash[:notice] = 'FundRequest was successfully destroyed.'
      format.html { redirect_to( profile_url ) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @fund_grant = FundGrant.find params[:fund_grant_id] if params[:fund_grant_id]
    @fund_request = FundRequest.find params[:id] if params[:id]
    @fund_source = FundSource.find params[:fund_source_id] if params[:fund_source_id]
    @fund_source ||= @fund_request.fund_grant.fund_source if @fund_request
    @organization = Organization.find params[:organization_id] if params[:organization_id]
    @organization ||= @fund_request.fund_grant.organization if @organization
    @context = @fund_grant || @fund_source || @organization
  end

  def initialize_index
    @fund_requests = FundRequest.scoped
    @fund_requests = @fund_requests.scoped( :conditions => { :organization_id => @organization.id } ) if @organization
    @fund_requests = @fund_requests.scoped( :conditions => { :fund_source_id => @fund_source.id }) if @fund_source
#    @fund_requests = @fund_requests.with_permissions_to(:show)
  end

  def new_fund_request_from_params
    @fund_request = @organization.fund_requests.build( params[:fund_request] )
  end

  def setup_breadcrumbs
    if @fund_source && permitted_to?( :review, @fund_request )
      add_breadcrumb @fund_source.name, url_for( @fund_source )
      add_breadcrumb 'FundRequests', fund_source_fund_requests_path( @fund_source )
    end
    if @organization
      add_breadcrumb @organization.name, url_for( @organization )
      add_breadcrumb 'FundRequests', organization_fund_requests_path( @organization )
    end
  end

  def csv_index
    csv_string = ""
    CSV.generate(csv_string) do |csv|
      csv << ( ['organizations', 'independent?','club sport?','status','fund_request','review','allocation'] + Category.all.map { |c| "#{c.name} allocation" } )
      @search.each do |fund_request|
        next unless permitted_to?( :review, fund_request )
        csv << ( [ fund_request.fund_grant.organization.name,
                   ( fund_request.fund_grant.organization.independent? ? 'Yes' : 'No' ),
                   ( fund_request.fund_grant.organization.club_sport? ? 'Yes' : 'No' ),
                   fund_request.status,
                   "#{fund_request.fund_editions.where(:perspective => 'requestor').sum('amount')}",
                   "#{fund_request.fund_editions.where(:perspective => 'reviewer').sum('amount')}",
                   "#{fund_request.fund_items.sum('fund_items.amount')}" ] + Category.all.map { |c| "#{fund_request.fund_items.allocation_for_category(c)}" } )
      end
    end
    send_data csv_string, :disposition => "attachment; filename=fund_requests.csv", :type => 'text/csv'
  end

end

