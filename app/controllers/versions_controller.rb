class VersionsController < ApplicationController
  # GET /items/:item_id/versions
  # GET /items/:item_id/versions.xml
  def index
    @item = Item.find(params[:item_id])
    @versions = @item.versions

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @versions }
    end
  end

  # GET /versions/1
  # GET /versions/1.xml
  def show
    @version = Version.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @version }
    end
  end

  # GET /items/:item_id/versions/new
  # GET /items/:item_id/versions/new.xml
  def new
    @version = Item.find(params[:item_id]).versions.build
    @version.stage_id = @version.item.versions.next_stage
    if @version.stage_id > 0:
      @prev_version = @version.item.versions.prev_version(@version.stage_id)
      @version.requestable = @prev_version.requestable.clone
    else
      @version.requestable = @version.build_requestable
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @version }
    end
  end

  # GET /versions/1/edit
  def edit
    @version = Version.find(params[:id])
    @prev_version = @version.item.versions.prev_version(@version.stage_id)
  end

  # POST /items/:item_id/versions
  # POST /items/:item_id/versions.xml
  def create
    @version = Item.find(params[:item_id]).versions.build
    @version.stage_id = params[:stage_pos]
    if @version.stage_id > 0:
      @prev_version = @version.item.versions.prev_version(@version.stage_id)
      @version.requestable = @prev_version.requestable.clone
    else
      @version.requestable = @version.item.node.requestable_type.constantize.new
    end
    @version.attributes = params[:version]

    respond_to do |format|
      if @version.save
        flash[:notice] = 'Version was successfully created.'
        format.html { redirect_to(@version) }
        format.xml  { render :xml => @version, :status => :created, :location => @version }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @version.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /versions/1
  # PUT /versions/1.xml
  def update
    @version = Version.find(params[:id])
    @prev_version = @version.item.versions.prev_version(@version.stage_id)

    respond_to do |format|
      if @version.update_attributes(params[:version])
        flash[:notice] = 'Version was successfully updated.'
        format.html { redirect_to(@version) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @version.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /versions/1
  # DELETE /versions/1.xml
  def destroy
    @version = Version.find(params[:id])
    @version.destroy

    respond_to do |format|
      format.html { redirect_to(versions_url) }
      format.xml  { head :ok }
    end
  end
end

