class RequestsController < ApplicationController
  # GET /organizations/:organization_id/requests
  # GET /organizations/:organization_id/requests.xml
  def index
    @organization = Organization.find(params[:organization_id])
    @requests = @organization.requests

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @requests }
    end
  end

  # GET /requests/1
  # GET /requests/1.xml
  def show
    @request = Request.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @request }
    end
  end

  # GET /organizations/:organization_id/requests/new
  # GET /organizations/:organization_id/requests/new.xml
  def new
    @organization = Organization.find(params[:organization_id])
    @request = @organization.requests.build
    @request.basis = Basis.find(params[:basis_id]) if params.has_key?(:basis_id)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @request }
    end
  end

  # POST /organizations/:organization_id/requests
  # POST /organizations/:organization_id/requests.xml
  def create
    @organization = Organization.find(params[:organization_id])
    @request = @organization.requests.build(params[:request])

    respond_to do |format|
      if @request.save
        flash[:notice] = 'Request was successfully created.'
        format.html { redirect_to(@request) }
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
  end

  # PUT /requests/1
  # PUT /requests/1.xml
  def update
    @request = Request.find(params[:id])

    respond_to do |format|
      if @request.update_attributes(params[:request])
        flash[:notice] = 'Request was successfully updated.'
        format.html { redirect_to(@request) }
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
    @request.destroy

    respond_to do |format|
      format.html { redirect_to(organization_requests_url(@request.organization)) }
      format.xml  { head :ok }
    end
  end

  # POST /requests/:request_id/approve
  # POST /requests/:request_id/approve.xml
  def approve
    @approval = Request.find(params[:request_id]).approvals.build(:user => current_user)

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

