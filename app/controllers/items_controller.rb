class ItemsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_item_from_request, :only => [ :new, :create ]
  before_filter :populate_editions, :only => [ :new, :edit ]
  filter_access_to :new, :edit, :destroy, :show, :attribute_check => true
  # The following checks are necessary to assure the user has permission to
  # create or update any editions he or she has asked to create or update
  filter_access_to :create do
    permitted_to! :create, @item
    @item.editions.each { |edition| permitted_to! :create, edition }
  end
  filter_access_to :update do
    permitted_to! :update, @item
    @item.editions.each do |edition|
      next unless edition.nested_changed?
      if edition.new_record?
        permitted_to! :create, edition
      else
        permitted_to! :update, edition
      end
    end
  end
  filter_access_to :index do
    permitted_to!( :show, @request )
  end


  # GET /requests/:request_id/items
  # GET /requests/:request_id/items.xml
  def index
    respond_to do |format|
      format.html { render :action => 'index' }  # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  # GET /items/1
  # GET /items/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /requests/:request_id/items/new
  # GET /requests/:request_id/items/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # POST /requests/:request_id/items
  # POST /requests/:request_id/items.xml
  def create
    respond_to do |format|
      if @item.save
        flash[:notice] = 'Item was successfully created.'
        format.html { redirect_to @item }
        format.xml  { render :xml => @item, :status => :created, :location => @item }
      else
        populate_editions
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /items/1/edit
  def edit
    respond_to do |format|
      format.html { render :action => 'edit' }
    end
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
    respond_to do |format|
      if @item.save
        flash[:notice] = 'Item was successfully updated.'
        format.html { redirect_to @item }
        format.xml  { head :ok }
      else
        populate_editions
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  def destroy
    @item.destroy

    respond_to do |format|
      flash[:notice] = 'Item was successfully destroyed.'
      format.html { redirect_to request_items_url @item.request }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @item = Item.find( params[:id], :include => { :editions => :documents } ) if params[:id]
    @request = Request.find params[:request_id] if params[:request_id]
    @request ||= @item.request if @item
    @item.attributes = params[:item] if @item && params[:item]
    if @request
      add_breadcrumb @request.organization.name, url_for( @request.organization )
      add_breadcrumb "#{@request.basis.name} request", url_for( @request )
      add_breadcrumb 'Items', request_items_path( @request )
    end
  end

  def initialize_index
    @items = @request.items.root if @request
    @items ||= Item.scoped.order( "items.position ASC" )
    # Skip explicit permissions check because if you can see the request, you can see items
  end

  def new_item_from_request
    @item = @request.items.build( params[:item] )
  end

  def populate_editions
    @item.editions.next
    @item.editions.each { |edition| edition.documents.populate }
  end
end

