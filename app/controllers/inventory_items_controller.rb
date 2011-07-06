class InventoryFundItemsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index, :active, :retired ]
  before_filter :new_inventory_fund_item_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :attribute_check => true
  filter_access_to :index do
    permitted_to!( :show, @organization ) if @organization
    permitted_to!( :index )
  end

  # GET /organizations/:organization_id/inventory_fund_items/retired
  def retired
    if @context
      add_breadcrumb 'Retired', polymorphic_path( [ :retired, @context, :inventory_fund_items ] )
    end
    @inventory_fund_items = @inventory_fund_items.retired
    index
  end

  # GET /organizations/:organization_id/inventory_fund_items/active
  def active
    if @context
      add_breadcrumb 'Active', polymorphic_path( [ :active, @context, :inventory_fund_items ] )
    end
    @inventory_fund_items = @inventory_fund_items.active
    index
  end

  # GET /organizations/:organization_id/inventory_fund_items
  # GET /organizations/:organization_id/inventory_fund_items.xml
  def index
    @search = @inventory_fund_items.with_permissions_to(:show).search( params[:search] )
    @inventory_fund_items = @search.paginate( :page => params[:page] )

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @inventory_fund_items }
    end
  end

  # GET /inventory_fund_items/1
  # GET /inventory_fund_items/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @inventory_fund_item }
    end
  end

  # GET /organizations/:organization_id/inventory_fund_items/new
  # GET /organizations/:organization_id/inventory_fund_items/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @inventory_fund_item }
    end
  end

  # GET /inventory_fund_items/1/edit
  def edit
  end

  # POST /organizations/:organization_id/inventory_fund_items
  # POST /organizations/:organization_id/inventory_fund_items.xml
  def create
    respond_to do |format|
      if @inventory_fund_item.save
        flash[:notice] = 'Inventory fund_item was successfully created.'
        format.html { redirect_to(@inventory_fund_item) }
        format.xml  { render :xml => @inventory_fund_item, :status => :created, :location => @inventory_fund_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @inventory_fund_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /inventory_fund_items/1
  # PUT /inventory_fund_items/1.xml
  def update
    respond_to do |format|
      if @inventory_fund_item.update_attributes(params[:inventory_fund_item])
        flash[:notice] = 'Inventory fund_item was successfully updated.'
        format.html { redirect_to(@inventory_fund_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @inventory_fund_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /inventory_fund_items/1
  # DELETE /inventory_fund_items/1.xml
  def destroy
    @inventory_fund_item.destroy

    respond_to do |format|
      format.html { redirect_to organization_inventory_fund_items_url @inventory_fund_item.organization }
      format.xml  { head :ok }
    end
  end

  def initialize_context
    @inventory_fund_item = InventoryFundItem.find params[:id] if params[:id]
    @organization = Organization.find params[:organization_id] if params[:organization_id]
    @organization ||= @inventory_fund_item.organization if @inventory_fund_item
    @context ||= @organization
    if @context
      add_breadcrumb @context, url_for( @context )
      add_breadcrumb 'Inventory fund_items', polymorphic_path( [ @context, :inventory_fund_items ] )
    end
  end

  def initialize_index
    @inventory_fund_items = InventoryFundItem.scoped
    @inventory_fund_items = @inventory_fund_items.scoped( :conditions => { :organization_id => @organization.id } ) if @organization
  end

  def new_inventory_fund_item_from_params
    @inventory_fund_item = @organization.inventory_fund_items.build( params[:inventory_fund_item] ) if @organization
  end

  def csv_index
    csv_string = CSV.generate do |csv|
      csv << ( %w( identifier acquired_on description purchase_price current_value ) )
      @inventory_fund_items.each do |fund_item|
        next unless permitted_to?( :show, fund_item )
        csv << ( [ fund_item.identifier, fund_item.acquired_on, fund_item.description,
          fund_item.purchase_price, fund_item.current_value ] )
      end
    end
    send_data csv_string, :disposition => "attachment; filename=inventory-fund_items.csv"
  end

end

