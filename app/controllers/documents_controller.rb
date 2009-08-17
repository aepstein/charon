class DocumentsController < ApplicationController
  # GET /versions/:version_id/documents
  # GET /versions/:version_id/documents.xml
  def index
    @version = Version.find(params[:version_id])
    @documents = @version.documents
    raise AuthorizationError unless @version.may_see? current_user

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @documents }
    end
  end

  # GET /documents/1
  # GET /documents/1.xml
  def show
    @document = Document.find(params[:id])
    raise AuthorizationError unless @document.may_see? current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @document }
    end
  end

  # GET /versions/:version_id/documents/new
  # GET /versions/:version_id/documents/new.xml
  def new
    @document = Version.find(params[:version_id]).documents.build
    raise AuthorizationError unless @document.may_create? current_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @document }
    end
  end

  # GET /documents/1/edit
  def edit
    @document = Document.find(params[:id])
    raise AuthorizationError unless @document.may_update? current_user
  end

  # POST /versions/:version_id/documents
  # POST /versions/:version_id/documents.xml
  def create
    @document = Version.find(params[:version_id]).documents.build(params[:document])
    raise AuthorizationError unless @document.may_create? current_user

    respond_to do |format|
      if @document.save
        flash[:notice] = 'Document was successfully created.'
        format.html { redirect_to(@document) }
        format.xml  { render :xml => @document, :status => :created, :location => @document }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /documents/1
  # PUT /documents/1.xml
  def update
    @document = Document.find(params[:id])
    raise AuthorizationError unless @document.may_update? current_user

    respond_to do |format|
      if @document.update_attributes(params[:document])
        flash[:notice] = 'Document was successfully updated.'
        format.html { redirect_to(@document) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.xml
  def destroy
    @document = Document.find(params[:id])
    raise AuthorizationError unless @document.may_destroy? current_user
    @document.destroy

    respond_to do |format|
      format.html { redirect_to( version_documents_url(@document.version) ) }
      format.xml  { head :ok }
    end
  end
end

