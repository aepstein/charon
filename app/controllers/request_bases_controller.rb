class RequestBasesController < ApplicationController
  # GET /request_bases
  # GET /request_bases.xml
  def index
    @request_bases = RequestBasis.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @request_bases }
    end
  end

  # GET /request_bases/1
  # GET /request_bases/1.xml
  def show
    @request_basis = RequestBasis.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @request_basis }
    end
  end

  # GET /request_bases/new
  # GET /request_bases/new.xml
  def new
    @request_basis = RequestBasis.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @request_basis }
    end
  end

  # GET /request_bases/1/edit
  def edit
    @request_basis = RequestBasis.find(params[:id])
  end

  # POST /request_bases
  # POST /request_bases.xml
  def create
    @request_basis = RequestBasis.new(params[:request_basis])

    respond_to do |format|
      if @request_basis.save
        flash[:notice] = 'RequestBasis was successfully created.'
        format.html { redirect_to(@request_basis) }
        format.xml  { render :xml => @request_basis, :status => :created, :location => @request_basis }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @request_basis.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /request_bases/1
  # PUT /request_bases/1.xml
  def update
    @request_basis = RequestBasis.find(params[:id])

    respond_to do |format|
      if @request_basis.update_attributes(params[:request_basis])
        flash[:notice] = 'RequestBasis was successfully updated.'
        format.html { redirect_to(@request_basis) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @request_basis.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /request_bases/1
  # DELETE /request_bases/1.xml
  def destroy
    @request_basis = RequestBasis.find(params[:id])
    @request_basis.destroy

    respond_to do |format|
      format.html { redirect_to(request_bases_url) }
      format.xml  { head :ok }
    end
  end
end

