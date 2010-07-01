class RequestsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_request_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :attribute_check => true
  filter_access_to :index do
    permitted_to!( :show, @organization ) if @organization
    permitted_to!( :show, @basis ) if @basis
    permitted_to!( :index )
  end

  # GET /organizations/:organization_id/requests
  # GET /organizations/:organization_id/requests.xml
  def index
    @search = @requests.searchlogic( params[:search] )
    @requests = @search.paginate( :page => params[:page] )

    respond_to do |format|
      format.html { render :action => 'index' }
      format.csv { csv_index }
      format.xml  { render :xml => @requests }
    end
  end

  # GET /requests/1
  # GET /requests/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @request }
    end
  end

  # GET /organizations/:organization_id/requests/new
  # GET /organizations/:organization_id/requests/new.xml
  # TODO -- should this action exist?
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @request }
    end
  end

  # POST /organizations/:organization_id/requests
  # POST /organizations/:organization_id/requests.xml
  def create
    respond_to do |format|
      if @request.save
        flash[:notice] = 'Request was successfully created.'
        format.html { redirect_to @request }
        format.xml  { render :xml => @request, :status => :created, :location => @request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /requests/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # PUT /requests/1
  # PUT /requests/1.xml
  def update
    respond_to do |format|
      if @request.update_attributes(params[:request])
        flash[:notice] = 'Request was successfully updated.'
        format.html { redirect_to @request }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /requests/1
  # DELETE /requests/1.xml
  def destroy
    @request.destroy

    respond_to do |format|
      flash[:notice] = 'Request was successfully destroyed.'
      format.html { redirect_to( profile_url ) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @basis = Basis.find params[:basis_id] if params[:basis_id]
    @organization = Organization.find params[:organization_id] if params[:organization_id]
    @context ||= @basis
    @context ||= @organization
    @request = Request.find params[:id] if params[:id]
  end

  def initialize_index
    @requests = Request
    @requests = @requests.scoped( :conditions => { :organization_id => @organization.id } ) if @organization
    @requests = @requests.scoped( :conditions => { :basis_id => @basis.id }) if @basis
    @requests = @requests.with_permissions_to(:show)
  end

  def new_request_from_params
    @request = @organization.requests.build( params[:request] )
  end

  def csv_index
    csv_string = CSV.generate do |csv|
      csv << ( ['organizations','club sport?','status','request','review','allocation'] + Category.all.map { |c| "#{c.name} allocation" } )
      @requests.each do |request|
        next unless request.may_review? current_user
        csv << ( [ request.organization.name,
                   ( request.organization.club_sport? ? 'Yes' : 'No' ),
                   request.status,
                   "$#{request.editions.perspective_equals('requestor').sum('amount')}",
                   "$#{request.editions.perspective_equals('reviewer').sum('amount')}",
                   "$#{request.items.sum('items.amount')}" ] + Category.all.map { |c| "$#{request.items.allocation_for_category(c)}" } )
      end
    end
    send_data csv_string, :disposition => "attachment; filename=requests.csv"
  end

end

