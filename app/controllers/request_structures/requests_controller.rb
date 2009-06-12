class RequestStructures::RequestsController < ApplicationController
  # GET /request_structures/:request_structure_id/requests/new
  # GET /request_structures/:request_structure_id/requests/new.xml
  def new
    @request = RequestStructure.find(params[:request_structure_id]).requests.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @request }
    end
  end

  # POST /request_structures/:request_structure_id/requests
  # POST /request_structures/:request_structure_id/requests.xml
  def create
    @request = RequestStructure.find(params[:request_structure_id]).requests.build

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


end

