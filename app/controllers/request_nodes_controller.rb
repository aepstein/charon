class RequestNodesController < ApplicationController
  # GET /request_structures/:request_structure_id/request_nodes
  # GET /request_structures/:request_structure_id/request_nodes.xml
  def index
    @request_structure = RequestStructure.find(params[:request_structure_id])
    @request_nodes = @request_structure.request_nodes

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @request_nodes }
    end
  end

  # GET /request_nodes/1
  # GET /request_nodes/1.xml
  def show
    @request_node = RequestNode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @request_node }
    end
  end

  # GET /request_structures/:request_structure_id/request_nodes/new
  # GET /request_structures/:request_structure_id/request_nodes/new.xml
  def new
    @request_node = RequestStructure.find(params[:request_structure_id]).request_nodes.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @request_node }
    end
  end

  # GET /request_nodes/1/edit
  def edit
    @request_node = RequestNode.find(params[:id])
  end

  # POST /request_structures/:request_structure_id/request_nodes
  # POST /request_structures/:request_structure_id/request_nodes.xml
  def create
    @request_node = RequestStructure.find(params[:request_structure_id]).request_nodes.build(params[:request_node])

    respond_to do |format|
      if @request_node.save
        flash[:notice] = 'RequestNode was successfully created.'
        format.html { redirect_to(@request_node) }
        format.xml  { render :xml => @request_node, :status => :created, :location => @request_node }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @request_node.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /request_nodes/1
  # PUT /request_nodes/1.xml
  def update
    @request_node = RequestNode.find(params[:id])

    respond_to do |format|
      if @request_node.update_attributes(params[:request_node])
        flash[:notice] = 'RequestNode was successfully updated.'
        format.html { redirect_to(@request_node) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @request_node.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /request_nodes/1
  # DELETE /request_nodes/1.xml
  def destroy
    @request_node = RequestNode.find(params[:id])
    @request_node.destroy

    respond_to do |format|
      format.html { redirect_to(request_nodes_url) }
      format.xml  { head :ok }
    end
  end
end

