class RequestItemsController < ApplicationController
  # GET /requests/:request_id/request_items
  # GET /requests/:request_id/request_items.xml
  def index
    @request = Request.find(params[:request_id])
    @request_items = @request.request_items

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @request_items }
    end
  end

  # GET /request_items/1
  # GET /request_items/1.xml
  def show
    @request_item = RequestItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @request_item }
    end
  end

  # GET /requests/:request_id/request_items/new
  # GET /requests/:request_id/request_items/new.xml
  def new
    @request_item = Request.find(params[:request_id]).request_items.build
    @request_item.request_node = RequestNode.find(params[:request_node_id])
    @request_item.requestable_type = @request_item.request_node.requestable_type
    @request_item.parent = Request.find(params[:parent_id]) if params.has_key?(:parent_id)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @request_item }
    end
  end

  # GET /request_items/1/edit
  def edit
    @request_item = RequestItem.find(params[:id])
  end

  # POST /requests/:request_id/request_items
  # POST /requests/:request_id/request_items.xml
  def create
    @request_item = Request.find(params[:request_id]).request_items.build(params[:request_item])

    respond_to do |format|
      if @request_item.save
        flash[:notice] = 'RequestItem was successfully created.'
        format.html { redirect_to(@request_item) }
        format.xml  { render :xml => @request_item, :status => :created, :location => @request_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @request_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /request_items/1
  # PUT /request_items/1.xml
  def update
    @request_item = RequestItem.find(params[:id])

    respond_to do |format|
      if @request_item.update_attributes(params[:request_item])
        flash[:notice] = 'RequestItem was successfully updated.'
        format.html { redirect_to(@request_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @request_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /request_items/1
  # DELETE /request_items/1.xml
  def destroy
    @request_item = RequestItem.find(params[:id])
    @request_item.destroy

    respond_to do |format|
      format.html { redirect_to(request_items_url) }
      format.xml  { head :ok }
    end
  end
end

