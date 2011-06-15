class NodesController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_node_from_params, :only => [ :new, :create ]
  filter_access_to :show, :new, :create, :edit, :update, :destroy, :attribute_check => true

  # GET /structures/:structure_id/nodes
  # GET /structures/:structure_id/nodes.xml
  def index
    @nodes = @nodes.paginate( :page => params[:page] )
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @nodes }
    end
  end

  # GET /nodes/1
  # GET /nodes/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @node }
    end
  end

  # GET /structures/:structure_id/nodes/new
  # GET /structures/:structure_id/nodes/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @node }
    end
  end

  # GET /nodes/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # POST /structures/:structure_id/nodes
  # POST /structures/:structure_id/nodes.xml
  def create
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
    @node.destroy

    respond_to do |format|
      format.html { redirect_to(structure_nodes_url(@node.structure)) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @node = Node.find params[:id] if params[:id]
    @structure = Structure.find params[:structure_id] if params[:structure_id]
    @structure ||= @node.structure if @node
    if @structure
      add_breadcrumb @structure.name, url_for( @structure )
      add_breadcrumb 'Nodes', structure_nodes_path( @structure )
    end
  end

  def initialize_index
    @nodes = @structure.nodes
  end

  def new_node_from_params
    @node = @structure.nodes.build( params[:node] )
  end
end

