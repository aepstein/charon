class AttachmentTypesController < ApplicationController
  # GET /attachment_types
  # GET /attachment_types.xml
  def index
    @attachment_types = AttachmentType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @attachment_types }
    end
  end

  # GET /attachment_types/1
  # GET /attachment_types/1.xml
  def show
    @attachment_type = AttachmentType.find(params[:id])
    raise AuthorizationError unless @attachment_type.may_see? current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @attachment_type }
    end
  end

  # GET /attachment_types/new
  # GET /attachment_types/new.xml
  def new
    @attachment_type = AttachmentType.new
    raise AuthorizationError unless @attachment_type.may_create? current_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @attachment_type }
    end
  end

  # GET /attachment_types/1/edit
  def edit
    @attachment_type = AttachmentType.find(params[:id])
    raise AuthorizationError unless @attachment_type.may_update? current_user
  end

  # POST /attachment_types
  # POST /attachment_types.xml
  def create
    @attachment_type = AttachmentType.new(params[:attachment_type])
    raise AuthorizationError unless @attachment_type.may_create? current_user

    respond_to do |format|
      if @attachment_type.save
        flash[:notice] = 'AttachmentType was successfully created.'
        format.html { redirect_to(@attachment_type) }
        format.xml  { render :xml => @attachment_type, :status => :created, :location => @attachment_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @attachment_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /attachment_types/1
  # PUT /attachment_types/1.xml
  def update
    @attachment_type = AttachmentType.find(params[:id])
    raise AuthorizationError unless @attachment_type.may_update? current_user

    respond_to do |format|
      if @attachment_type.update_attributes(params[:attachment_type])
        flash[:notice] = 'AttachmentType was successfully updated.'
        format.html { redirect_to(@attachment_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @attachment_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /attachment_types/1
  # DELETE /attachment_types/1.xml
  def destroy
    @attachment_type = AttachmentType.find(params[:id])
    raise AuthorizationError unless @attachment_type.may_destroy? current_user
    @attachment_type.destroy

    respond_to do |format|
      format.html { redirect_to(attachment_types_url) }
      format.xml  { head :ok }
    end
  end
end

