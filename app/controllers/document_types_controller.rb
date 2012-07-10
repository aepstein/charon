class DocumentTypesController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_document_type_from_params, :only => [ :new, :create ]
  filter_access_to :show, :edit, :update, :new, :create, :destroy, :attribute_check => true

  # GET /document_types
  # GET /document_types.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @document_types }
    end
  end

  # GET /document_types/1
  # GET /document_types/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @document_type }
    end
  end

  # GET /document_types/new
  # GET /document_types/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @document_type }
    end
  end

  # GET /document_types/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # POST /document_types
  # POST /document_types.xml
  def create
    respond_to do |format|
      if @document_type.save
        flash[:notice] = 'Document type was successfully created.'
        format.html { redirect_to(@document_type) }
        format.xml  { render :xml => @document_type, :status => :created, :location => @document_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @document_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /document_types/1
  # PUT /document_types/1.xml
  def update
    respond_to do |format|
      if @document_type.update_attributes(params[:document_type])
        flash[:notice] = 'Document type was successfully updated.'
        format.html { redirect_to(@document_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @document_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /document_types/1
  # DELETE /document_types/1.xml
  def destroy
    @document_type.destroy
    flash[:notice] = 'Document type was successfully destroyed.'

    respond_to do |format|
      format.html { redirect_to document_types_url }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @document_type = DocumentType.find params[:id] if params[:id]
    add_breadcrumb 'Document types', document_types_path
  end

  def initialize_index
    @document_types = DocumentType.scoped.ordered
  end

  def new_document_type_from_params
    @document_type = DocumentType.new( params[:document_type] )
  end

end

