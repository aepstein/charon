class RequestsController < ApplicationController
  before_filter :require_user

  # GET /organizations/:organization_id/requests
  # GET /organizations/:organization_id/requests.xml
  def index
    page = params[:page] ? params[:page] : 1
    @organization = Organization.find(params[:organization_id]) if params[:organization_id]
    @basis = Basis.find(params[:basis_id]) if params[:basis_id]
    if params[:search]
      q = params[:search][:q]
      status = params[:search][:status]
    else
      q = ''
      status = ''
    end
    if @organization
      @requests = @organization.requests.status_like(status).basis_like(q)
    end
    if @basis
      @requests = @basis.requests.status_like(status).organization_like(q)
    end
    @requests ||= Request.all

    respond_to do |format|
      format.html { @requests = @requests.paginate(:page => page) } # index.html.erb
      format.csv do
        csv_string = FasterCSV.generate do |csv|
          csv << ( ['organizations','club sport?','status','request','review','allocation'] + Category.all.map { |c| "#{c.name} allocation" } )
          @requests.each do |request|
            next unless request.may_review? current_user
            csv << ( [ request.organizations.map { |o| o.name }.join(', '),
                     request.organizations.map { |o| o.club_sport? ? 'Y' : 'N' }.join(', '),
                     request.status,
                     "$#{request.editions.perspective_equals('requestor').sum('amount')}",
                     "$#{request.editions.perspective_equals('reviewer').sum('amount')}",
                     "$#{request.items.sum('items.amount')}" ] + Category.all.map { |c| "$#{request.items.allocation_for_category(c)}" } )
          end
        end
        send_data csv_string, :disposition => "attachment; filename=requests.csv"
      end
      format.xml  { render :xml => @requests }
    end
  end

  # GET /requests/1
  # GET /requests/1.xml
  def show
    @request = Request.find(params[:id])
    raise AuthorizationError unless @request.may_see?(current_user)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @request }
    end
  end

  # GET /requests/1/supporting_documents
  def supporting_documents
    @request = Request.find(params[:id])
    raise AuthorizationError unless @request.may_see? current_user

    respond_to do |format|
      format.html # supporting_documents.html.erb
    end
  end

  # GET /organizations/:organization_id/requests/new
  # GET /organizations/:organization_id/requests/new.xml
  # TODO -- should this action exist?
  def new
    @organization = Organization.find(params[:organization_id])
    @request = Request.new
    @request.organizations << @organization
    @request.basis = Basis.find(params[:basis_id]) if params.has_key?(:basis_id)
    raise AuthorizationError unless @request.may_create?(current_user)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @request }
    end
  end

  # POST /organizations/:organization_id/requests
  # POST /organizations/:organization_id/requests.xml
  def create
    @request = Request.new(params[:request])
    @organization = Organization.find(params[:organization_id])
    @request.organizations << @organization
    raise AuthorizationError unless @request.may_create?(current_user)

    respond_to do |format|
      if @request.save
        flash[:notice] = 'Request was successfully created.'
        format.html { redirect_to(request_items_path(@request)) }
        format.xml  { render :xml => @request, :status => :created, :location => @request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /requests/1/edit
  def edit
    @request = Request.find(params[:id])
    raise AuthorizationError unless @request.may_update?(current_user)
  end

  # PUT /requests/1
  # PUT /requests/1.xml
  def update
    @request = Request.find(params[:id])
    raise AuthorizationError unless @request.may_update?(current_user)

    respond_to do |format|
      if @request.update_attributes(params[:request])
        flash[:notice] = 'Request was successfully updated.'
        format.html { redirect_to(request_items_path(@request)) }
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
    @request = Request.find(params[:id])
    raise AuthorizationError unless @request.may_destroy?(current_user)
    @request.destroy

    respond_to do |format|
      flash[:notice] = 'Request was successfully destroyed.'
      format.html { redirect_to( profile_url ) }
      format.xml  { head :ok }
    end
  end

  # POST /requests/:request_id/approve
  # POST /requests/:request_id/approve.xml
  def approve
    @approval = Request.find(params[:request_id]).approvals.build(:user => current_user)
    raise AuthorizationError unless @request.may_approve?(current_user)

    respond_to do |format|
      if @approval.save
        flash[:notice] = 'Approval was successfully created.'
        format.html { redirect_to(@approval) }
        format.xml  { render :xml => @approval, :status => :created, :location => @approval }
      else
        # TODO how to handle a failed approval.
        format.html { render :action => "show" }
        format.xml  { render :xml => @approval.errors, :status => :unprocessable_entity }
      end
    end
  end

end

