class NodesController < ApplicationController
  # GET /structures/:structure_id/nodes
  # GET /structures/:structure_id/nodes.xml
  def index
    @structure = Structure.find(params[:structure_id])
    @nodes = @structure.nodes
    raise AuthorizationError unless @structure.may_see?(current_user)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @nodes }
    end
  end

  # GET /nodes/1
  # GET /nodes/1.xml
  def show
    @node = Node.find(params[:id])
    raise AuthorizationError unless @node.may_see?(current_user)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @node }
    end
  end

  # GET /structures/:structure_id/nodes/new
  # GET /structures/:structure_id/nodes/new.xml
  def new
    @node = Structure.find(params[:structure_id]).nodes.build
    raise AuthorizationError unless @node.may_create?(current_user)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @node }
    end
  end

  # GET /nodes/1/edit
  def edit
    @node = Node.find(params[:id])
    raise AuthorizationError unless @node.may_update?(current_user)
  end

  # POST /structures/:structure_id/nodes
  # POST /structures/:structure_id/nodes.xml
  def create
    @node = Structure.find(params[:structure_id]).nodes.build(params[:node])
    raise AuthorizationError unless @node.may_create?(current_user)

    respond_to do |format|
      if @node.save
        flash[:notice] = 'Node was successfully created.'
        format.html { redirect_to(@node) }
        format.xml  { render :xml => @node, :status => :created, :location => @node }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @node.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /nodes/1
  # PUT /nodes/1.xml
  def update
    @node = Node.find(params[:id])
    raise AuthorizationError unless @node.may_update?(current_user)

    respond_to do |format|
      if @node.update_attributes(params[:node])
        flash[:notice] = 'Node was successfully updated.'
        format.html { redirect_to(@node) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @node.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /nodes/1
  # DELETE /nodes/1.xml
  def destroy
    @node = Node.find(params[:id])
    raise AuthorizationError unless @node.may_destroy?(current_user)
    @node.destroy

    respond_to do |format|
      format.html { redirect_to(structure_nodes_url(@node.structure)) }
      format.xml  { head :ok }
    end
  end
end

