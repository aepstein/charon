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
    @inventory_items = @inventory_items.retired
  end

  # GET /organizations/:organization_id/inventory_items/active
  def active
    @inventory_items = @inventory_items.active
  end

  # GET /organizations/:organization_id/inventory_items
  # GET /organizations/:organization_id/inventory_items.xml
  def index
    @search = @inventory_items.with_permissions_to(:show).searchlogic( params[:search] )
    @inventory_items = @search.paginate( :page => params[:page] )

    respond_to do |format|
      format.html # index.html.erb
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
    @organization = Organization.find params[:organization_id] if params[:organization_id]
    @context ||= @organization
    @inventory_item = InventoryItem.find params[:id] if params[:id]
  end

  def initialize_index
    @inventory_items = InventoryItem
    @inventory_items = @inventory_items.scoped( :conditions => { :organization_id => @organization.id } ) if @organization
  end

  def new_inventory_item_from_params
    @inventory_item = @organization.inventory_items.build( params[:inventory_item] ) if @organization
  end

  def csv_index
    csv_string = CSV.generate do |csv|
      csv << ( %w( identifier acquired_on description purchase_price current_value ) )
      @inventory_items.each do |item|
        next unless permitted_to?( :show, item )
        csv << ( [ item.identifier, item.acquired_on, item.description,
          item.purchase_price, item.current_value ] )
      end
    end
    send_data csv_string, :disposition => "attachment; filename=inventory-items.csv"
  end

end

