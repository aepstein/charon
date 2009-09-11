class ItemsController < ApplicationController
  before_filter :require_user

  # GET /requests/:request_id/items
  # GET /requests/:request_id/items.xml
  def index
    @request = Request.find(params[:request_id])
    raise AuthorizationError unless @request.may_see?(current_user)
    @items = @request.items.root


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  # GET /items/1
  # GET /items/1.xml
  def show
    @item = Item.find(params[:id])
    raise AuthorizationError unless @item.may_see?(current_user)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /requests/:request_id/items/new
  # GET /requests/:request_id/items/new.xml
  def new
    @item = Request.find(params[:request_id]).items.build(params[:item])
    raise AuthorizationError unless @item.may_create?(current_user)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # POST /requests/:request_id/items
  # POST /requests/:request_id/items.xml
  def create
    @item = Request.find(params[:request_id]).items.build(params[:item])
    raise AuthorizationError unless @item.may_create?(current_user)

    respond_to do |format|
      if @item.save
        flash[:notice] = 'Item was successfully created.'
        format.html { redirect_to( request_items_url(@item.request) ) }
        format.xml  { render :xml => @item, :status => :created, :location => @item }

      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
    raise AuthorizationError unless @item.may_update? current_user
  end

  # GET /items/1/move
  def move
    @item = Item.find(params[:id])
    raise AuthorizationError unless @item.may_update? current_user
  end

  # PUT /items/1/do_move
  def do_move
    @item = Item.find(params[:id])
    raise AuthorizationError unless @item.may_update? current_user

    respond_to do |format|
      if @item.insert_at(params[:new_position].to_i)
        flash[:notice] = 'Item was successfully moved.'
        format.html { redirect_to( request_items_url(@item.request) ) }
      else
        format.html { render :action => 'move' }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
    @item = Item.find(params[:id])
    raise AuthorizationError unless @item.may_update?(current_user)

    respond_to do |format|
      if @item.update_attributes(params[:item])
        flash[:notice] = 'Item was successfully updated.'
        format.html { redirect_to(@item) }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  def destroy
    @item = Item.find(params[:id])
    raise AuthorizationError unless @item.may_destroy?(current_user)
    @item.destroy

    respond_to do |format|
      flash[:notice] = 'Item was successfully destroyed.'
      format.html { redirect_to( request_items_url(@item.request) ) }
      format.xml  { head :ok }
    end
  end
end

