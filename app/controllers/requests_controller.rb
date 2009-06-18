class RequestsController < ApplicationController
  # GET /bases/:basis_id/requests
  # GET /bases/:basis_id/requests.xml
  def index
    @basis = Basis.find(params[:basis_id])
    @requests = @basis.requests

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

  # GET /bases/:basis_id/requests/new
  # GET /bases/:basis_id/requests/new.xml
  def new
    @request = Basis.find(params[:basis_id]).requests.build
    @request.items.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @request }
    end
  end

  # POST /bases/:basis_id/requests
  # POST /bases/:basis_id/requests.xml
  def create
    @request = Basis.find(params[:basis_id]).requests.build

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
      format.html { redirect_to(basis_requests_url(@request.basis)) }
      format.xml  { head :ok }
    end
  end

end

