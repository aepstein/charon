class FundRequestsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index, :duplicate, :inactive ]
  before_filter :new_fund_request_from_params, :only => [ :new, :create ]
  before_filter :setup_breadcrumbs
  filter_access_to :new, :create, :edit, :update, :reject, :do_reject, :destroy,
    :show, :submit, :withdraw, :reconsider, :attribute_check => true
  filter_access_to :documents_report do
    permitted_to! :show, @fund_request
  end
  filter_access_to :index, :duplicate, :inactive do
    permitted_to!( :show, @organization ) if @organization
    permitted_to!( :show, @fund_source ) if @fund_source
    permitted_to!( :show, @fund_queue.fund_source ) if @fund_queue && @fund_queue.fund_source
    true
  end
  filter_access_to :reviews_report do
    permitted_to!( :review, @fund_queue.fund_source )
  end

  def inactive
    @fund_requests = @fund_requests.inactive
    index
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

  # GET /fund_queues/:fund_queue_id/fund_requests/reviews_report.csv
  def reviews_report
    respond_to do |format|
      format.csv do
        send_data @fund_queue.fund_requests.reviews_report,
          :filename => "fund_queue_#{@fund_queue.id}_reviews_report.csv",
          :type => :csv, :disposition => 'attachment'
      end
    end
  end

  # PUT /fund_requests/:id/withdraw
  def withdraw
    @fund_request.withdrawn_by_user = current_user
    @fund_request.withdraw!
    flash[:notice] = 'Fund request was successfully withdrawn.'
    respond_to do |format|
      format.html { redirect_to :back }
      format.xml { head :ok }
    end
  end

  # PUT /fund_requests/:id/reconsider
  def reconsider
    @fund_request.reconsider_review!
    flash[:notice] = 'Fund request was marked for reconsideration.'
    respond_to do |format|
      format.html { redirect_to :back }
      format.xml { head :ok }
    end
  end

  def submit
    @fund_request.submit!
    flash[:notice] = 'Fund request was successfully submitted.'
    respond_to do |format|
      format.html { redirect_to :back }
      format.xml { head :ok }
     end
  end

  def reject; end

  def do_reject
    @fund_request.assign_attributes( params[:fund_request], :as => :rejector )
    if @fund_request.reject
      flash[:notice] = 'Fund request was successfully rejected.'
      respond_to do |format|
        format.html { redirect_to @fund_request }
        format.xml  { xmlhead :ok }
      end
    else
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
    @search = params[:search] || Hash.new
    @search.each do |k,v|
      if !v.blank? && FundRequest::SEARCHABLE.include?( k.to_sym )
        if %w( with_state with_review_state ).include?( k )
          v = v.to_sym
        end
        @fund_requests = @fund_requests.send k, v
      end
    end
    @fund_requests = @fund_requests.page(params[:page])

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
        flash[:notice] = 'Fund request was successfully created.'
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
        flash[:notice] = 'Fund request was successfully updated.'
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
      flash[:notice] = 'Fund request was successfully destroyed.'
      format.html { redirect_to( profile_url ) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @fund_grant = FundGrant.find params[:fund_grant_id] if params[:fund_grant_id]
    @fund_request = FundRequest.find params[:id] if params[:id]
    @fund_grant = @fund_request.fund_grant if @fund_request
    @fund_source = FundSource.find params[:fund_source_id] if params[:fund_source_id]
    @fund_source ||= @fund_request.fund_grant.fund_source if @fund_request
    @organization = Organization.find params[:organization_id] if params[:organization_id]
    @organization ||= @fund_request.fund_grant.organization if @organization
    @fund_queue = FundQueue.find params[:fund_queue_id] if params[:fund_queue_id]
    @context = @fund_queue || @fund_grant || @fund_source || @organization
  end

  def initialize_index
    @fund_requests = FundRequest.scoped.ordered
    if @organization
      @fund_requests = @fund_requests.
        where { |r| r.fund_grants.organization_id == @organization.id }
    end
    if @fund_source
      @fund_requests = @fund_requests.
        where { |r| r.fund_grants.fund_source_id == @fund_source.id }
    end
    if @fund_queue
      @fund_requests = @fund_requests.
        where { |r| r.fund_queue_id == @fund_queue.id }
    end
#    @fund_requests = @fund_requests.with_permissions_to(:show)
  end

  def new_fund_request_from_params
    @fund_request = @fund_grant.fund_requests.build( params[:fund_request] )
  end

  def setup_breadcrumbs
    if @fund_source && permitted_to?( :review, @fund_request )
      add_breadcrumb @fund_source.name, url_for( @fund_source )
      add_breadcrumb 'Fund Requests', fund_source_fund_requests_path( @fund_source )
    end
    if @organization
      add_breadcrumb @organization.name, url_for( @organization )
      add_breadcrumb 'Fund Requests', organization_fund_requests_path( @organization )
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

