class RequestsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index, :duplicate ]
  before_filter :new_request_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :reject, :do_reject, :destroy, :show, :attribute_check => true
  filter_access_to :index, :duplicate do
    permitted_to!( :show, @organization ) if @organization
    permitted_to!( :show, @basis ) if @basis
    permitted_to!( :index )
  end

  def reject; end

  def do_reject
    unless params[:request].blank? || params[:request][:reject_message].blank?
      @request.update_attribute :reject_message, params[:request][:reject_message]
      @request.reject!
      flash[:notice] = 'Request was successfully rejected.'
      respond_to do |format|
        format.html { redirect_to @request }
        format.xml  { head :ok }
      end
    else
      @request.errors.add :reject_message, "cannot be empty."
      respond_to do |format|
        format.html { render :action => "reject" }
        format.xml  { render :xml => @request.errors, :status => :unprocessable_entity }
      end
    end
  end

  def duplicate
    @requests = @requests.duplicate
    index
  end

  # GET /organizations/:organization_id/requests
  # GET /organizations/:organization_id/requests.xml
  def index
    @search = @requests.search( params[:search] )
    @requests = @search.paginate( :page => params[:page], :per_page => 10, :include => {
      :approvals => [], :basis =>  { :organization => [:memberships], :framework => [] }
    } )

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
#    @requests = @requests.with_permissions_to(:show)
  end

  def new_request_from_params
    @request = @organization.requests.build( params[:request] )
  end

  def csv_index
    csv_string = ""
    CSV.generate(csv_string) do |csv|
      csv << ( ['organizations', 'independent?','club sport?','status','request','review','allocation'] + Category.all.map { |c| "#{c.name} allocation" } )
      @search.each do |request|
        next unless permitted_to?( :review, request )
        csv << ( [ request.organization.name,
                   ( request.organization.independent? ? 'Yes' : 'No' ),
                   ( request.organization.club_sport? ? 'Yes' : 'No' ),
                   request.status,
                   "#{request.editions.where(:perspective => 'requestor').sum('amount')}",
                   "#{request.editions.where(:perspective => 'reviewer').sum('amount')}",
                   "#{request.items.sum('items.amount')}" ] + Category.all.map { |c| "#{request.items.allocation_for_category(c)}" } )
      end
    end
    send_data csv_string, :disposition => "attachment; filename=requests.csv", :type => 'text/csv'
  end

end

