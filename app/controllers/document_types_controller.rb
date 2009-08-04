class DocumentTypesController < ApplicationController
  # GET /document_types
  # GET /document_types.xml
  def index
    @document_types = DocumentType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @document_types }
    end
  end

  # GET /document_types/1
  # GET /document_types/1.xml
  def show
    @document_type = DocumentType.find(params[:id])
    raise AuthorizationError unless @document_type.may_see? current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @document_type }
    end
  end

  # GET /document_types/new
  # GET /document_types/new.xml
  def new
    @document_type = DocumentType.new
    raise AuthorizationError unless @document_type.may_create? current_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @document_type }
    end
  end

  # GET /document_types/1/edit
  def edit
    @document_type = DocumentType.find(params[:id])
    raise AuthorizationError unless @document_type.may_update? current_user
  end

  # POST /document_types
  # POST /document_types.xml
  def create
    @document_type = DocumentType.new(params[:document_type])
    raise AuthorizationError unless @document_type.may_create? current_user

    respond_to do |format|
      if @document_type.save
        flash[:notice] = 'DocumentType was successfully created.'
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
    @document_type = DocumentType.find(params[:id])
    raise AuthorizationError unless @document_type.may_update? current_user

    respond_to do |format|
      if @document_type.update_attributes(params[:document_type])
        flash[:notice] = 'DocumentType was successfully updated.'
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
    @document_type = DocumentType.find(params[:id])
    raise AuthorizationError unless @document_type.may_destroy? current_user
    @document_type.destroy

    respond_to do |format|
      format.html { redirect_to(document_types_url) }
      format.xml  { head :ok }
    end
  end
end

