class ItemsController < ApplicationController
  # GET /requests/:request_id/items
  # GET /requests/:request_id/items.xml
  def index
    @request = Request.find(params[:request_id])
    @items = @request.items

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  # GET /items/1
  # GET /items/1.xml
  def show
    @item = Item.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /requests/:request_id/items/new
  # GET /requests/:request_id/items/new.xml
  def new
    @item = Request.find(params[:request_id]).items.build
    @item.node = Node.find(params[:node_id])
    @item.requestable = @item.node.requestable_type.constantize.new
    @item.parent = Request.find(params[:parent_id]) if params.has_key?(:parent_id)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
  end

  # POST /requests/:request_id/items
  # POST /requests/:request_id/items.xml
  def create
    @item = Request.find(params[:request_id]).items.build(params[:item])

    respond_to do |format|
      if @item.save
        flash[:notice] = 'Item was successfully created.'
        format.html { redirect_to(@item) }
        format.xml  { render :xml => @item, :status => :created, :location => @item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        flash[:notice] = 'Item was successfully updated.'
        format.html { redirect_to(@item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to(request_items_url(@item.request) }
      format.xml  { head :ok }
    end
  end
end

