class InventoryItemsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index, :active, :retired ]
  before_filter :new_inventory_item_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :attribute_check => true
  filter_access_to :index do
    permitted_to!( :show, @organization ) if @organization
    permitted_to!( :index )
  end

  # GET /organizations/:organization_id/inventory_items/retired
  def retired
    if @context
      add_breadcrumb 'Retired', polymorphic_path( [ :retired, @context, :inventory_items ] )
    end
    @inventory_items = @inventory_items.retired
    index
  end

  # GET /organizations/:organization_id/inventory_items/active
  def active
    if @context
      add_breadcrumb 'Active', polymorphic_path( [ :active, @context, :inventory_items ] )
    end
    @inventory_items = @inventory_items.active
    index
  end

  # GET /organizations/:organization_id/inventory_items
  # GET /organizations/:organization_id/inventory_items.xml
  def index
    @q = @inventory_items.search( params[:q] )
    @inventory_items = @q.result.page(params[:page])

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @inventory_items }
    end
  end

  # GET /inventory_items/1
  # GET /inventory_items/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @inventory_item }
    end
  end

  # GET /organizations/:organization_id/inventory_items/new
  # GET /organizations/:organization_id/inventory_items/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @inventory_item }
    end
  end

  # GET /inventory_items/1/edit
  def edit
  end

  # POST /organizations/:organization_id/inventory_items
  # POST /organizations/:organization_id/inventory_items.xml
  def create
    respond_to do |format|
      if @inventory_item.save
        flash[:notice] = 'Inventory item was successfully created.'
        format.html { redirect_to(@inventory_item) }
        format.xml  { render :xml => @inventory_item, :status => :created, :location => @inventory_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @inventory_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /inventory_items/1
  # PUT /inventory_items/1.xml
  def update
    respond_to do |format|
      if @inventory_item.update_attributes(params[:inventory_item])
        flash[:notice] = 'Inventory item was successfully updated.'
        format.html { redirect_to(@inventory_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @inventory_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /inventory_items/1
  # DELETE /inventory_items/1.xml
  def destroy
    @inventory_item.destroy

    respond_to do |format|
      format.html { redirect_to organization_inventory_items_url @inventory_item.organization }
      format.xml  { head :ok }
    end
  end

  def initialize_context
    @inventory_item = InventoryItem.find params[:id] if params[:id]
    @organization = Organization.find params[:organization_id] if params[:organization_id]
    @organization ||= @inventory_item.organization if @inventory_item
    @context ||= @organization
    if @context
      add_breadcrumb @context, url_for( @context )
      add_breadcrumb 'Inventory fund_items', polymorphic_path( [ @context, :inventory_items ] )
    end
  end

  def initialize_index
    @inventory_items = InventoryItem.scoped
    @inventory_items = @inventory_items.scoped( :conditions => { :organization_id => @organization.id } ) if @organization
    @inventory_items = @inventory_items.with_permissions_to(:show).ordered
  end

  def new_inventory_item_from_params
    @inventory_item = @organization.inventory_items.build( params[:inventory_item] ) if @organization
  end

  def csv_index
    csv_string = CSV.generate do |csv|
      csv << ( %w( identifier acquired_on description purchase_price current_value ) )
      @inventory_items.each do |fund_item|
        next unless permitted_to?( :show, fund_item )
        csv << ( [ fund_item.identifier, fund_item.acquired_on, fund_item.description,
          fund_item.purchase_price, fund_item.current_value ] )
      end
    end
    send_data csv_string, :disposition => "attachment; filename=inventory-fund_items.csv"
  end

end

