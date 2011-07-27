class StructuresController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_structure_from_params, :only => [ :new, :create ]
  filter_access_to :show, :new, :create, :edit, :update, :destroy, :attribute_check => true

  # GET /structures
  # GET /structures.xml
  def index
    @structures = @structures.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @structures }
    end
  end

  # GET /structures/1
  # GET /structures/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @structure }
    end
  end

  # GET /structures/new
  # GET /structures/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @structure }
    end
  end

  # GET /structures/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # POST /structures
  # POST /structures.xml
  def create
    respond_to do |format|
      if @structure.save
        flash[:notice] = 'Structure was successfully created.'
        format.html { redirect_to(@structure) }
        format.xml  { render :xml => @structure, :status => :created, :location => @structure }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @structure.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /structures/1
  # PUT /structures/1.xml
  def update
    respond_to do |format|
      if @structure.update_attributes(params[:structure])
        flash[:notice] = 'Structure was successfully updated.'
        format.html { redirect_to(@structure) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @structure.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /structures/1
  # DELETE /structures/1.xml
  def destroy
    @structure.destroy

    respond_to do |format|
      format.html { redirect_to(structures_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @structure = Structure.find params[:id] if params[:id]
    add_breadcrumb 'Structures', structures_path
  end

  def initialize_index
    @structures = Structure.scoped
  end

  def new_structure_from_params
    @structure = Structure.new( params[:structure] )
  end

end

