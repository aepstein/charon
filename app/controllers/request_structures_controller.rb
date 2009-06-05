class RequestStructuresController < ApplicationController
  # GET /request_structures
  # GET /request_structures.xml
  def index
    @request_structures = RequestStructure.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @request_structures }
    end
  end

  # GET /request_structures/1
  # GET /request_structures/1.xml
  def show
    @request_structure = RequestStructure.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @request_structure }
    end
  end

  # GET /request_structures/new
  # GET /request_structures/new.xml
  def new
    @request_structure = RequestStructure.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @request_structure }
    end
  end

  # GET /request_structures/1/edit
  def edit
    @request_structure = RequestStructure.find(params[:id])
  end

  # POST /request_structures
  # POST /request_structures.xml
  def create
    @request_structure = RequestStructure.new(params[:request_structure])

    respond_to do |format|
      if @request_structure.save
        flash[:notice] = 'RequestStructure was successfully created.'
        format.html { redirect_to(@request_structure) }
        format.xml  { render :xml => @request_structure, :status => :created, :location => @request_structure }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @request_structure.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /request_structures/1
  # PUT /request_structures/1.xml
  def update
    @request_structure = RequestStructure.find(params[:id])

    respond_to do |format|
      if @request_structure.update_attributes(params[:request_structure])
        flash[:notice] = 'RequestStructure was successfully updated.'
        format.html { redirect_to(@request_structure) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @request_structure.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /request_structures/1
  # DELETE /request_structures/1.xml
  def destroy
    @request_structure = RequestStructure.find(params[:id])
    @request_structure.destroy

    respond_to do |format|
      format.html { redirect_to(request_structures_url) }
      format.xml  { head :ok }
    end
  end
end
