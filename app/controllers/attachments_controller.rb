class AttachmentsController < ApplicationController
  # GET /versions/:version_id/attachments
  # GET /versions/:version_id/attachments.xml
  def index
    @version = Version.find(params[:version_id])
    @attachments = @version.attachments
    raise AuthorizationError unless @version.may_see? current_user

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @attachments }
    end
  end

  # GET /attachments/1
  # GET /attachments/1.xml
  def show
    @attachment = Attachment.find(params[:id])
    raise AuthorizationError unless @attachment.may_see? current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @attachment }
    end
  end

  # GET /versions/:version_id/attachments/new
  # GET /versions/:version_id/attachments/new.xml
  def new
    @attachment = Version.find(params[:version_id]).attachments.build
    raise AuthorizationError unless @attachment.may_create? current_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @attachment }
    end
  end

  # GET /attachments/1/edit
  def edit
    @attachment = Attachment.find(params[:id])
    raise AuthorizationError unless @attachment.may_update? current_user
  end

  # POST /versions/:version_id/attachments
  # POST /versions/:version_id/attachments.xml
  def create
    @attachment = Version.find(params[:version_id]).attachments.build(params[:attachment])
    raise AuthorizationError unless @attachment.may_create? current_user

    respond_to do |format|
      if @attachment.save
        flash[:notice] = 'Attachment was successfully created.'
        format.html { redirect_to(@attachment) }
        format.xml  { render :xml => @attachment, :status => :created, :location => @attachment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @attachment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /attachments/1
  # PUT /attachments/1.xml
  def update
    @attachment = Attachment.find(params[:id])
    raise AuthorizationError unless @attachment.may_update? current_user

    respond_to do |format|
      if @attachment.update_attributes(params[:attachment])
        flash[:notice] = 'Attachment was successfully updated.'
        format.html { redirect_to(@attachment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @attachment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /attachments/1
  # DELETE /attachments/1.xml
  def destroy
    @attachment = Attachment.find(params[:id])
    raise AuthorizationError unless @attachment.may_destroy? current_user
    @attachment.destroy

    respond_to do |format|
      format.html { redirect_to( version_attachments_url(@attachment.attachable) ) }
      format.xml  { head :ok }
    end
  end
end

