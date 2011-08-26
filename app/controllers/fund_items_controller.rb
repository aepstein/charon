class FundItemsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_fund_item_from_fund_request, :only => [ :new, :create ]
  before_filter :populate_fund_editions, :only => [ :new, :edit ]
  before_filter :attach_fund_request_to_new_fund_editions, :only => [ :create, :update ]
  filter_access_to :show, :destroy, :attribute_check => true
  # The following checks are necessary to assure the user has permission to
  # create or update any fund_editions he or she has asked to create or update
  filter_access_to :new do
    permitted_to! :update, @fund_request
    permitted_to! :new, @fund_item
  end
  filter_access_to :edit do
    permitted_to! :update, @fund_request
    permitted_to! :edit, @fund_item
  end
  filter_access_to :create do
    # TODO: Additional constraints for adding items here
    permitted_to! :update, @fund_request
    permitted_to! :create, @fund_item
    @fund_item.fund_editions.for_request( @fund_request ).
      each { |fund_edition| permitted_to! :create, fund_edition }
  end
  filter_access_to :update do
    # TODO: Additional constraints for changing items here
    permitted_to! :update, @fund_request
    permitted_to! :update, @fund_item
    @fund_item.fund_editions.for_request( @fund_request ).each do |fund_edition|
      next unless fund_edition.nested_changed?
      if fund_edition.new_record?
        permitted_to! :create, fund_edition
      else
        permitted_to! :update, fund_edition
      end
    end
  end
  filter_access_to :index do
    permitted_to!( :show, @fund_request )
  end


  # GET /fund_requests/:fund_request_id/fund_items
  # GET /fund_requests/:fund_request_id/fund_items.xml
  def index
    respond_to do |format|
      format.html { render :action => 'index' }  # index.html.erb
      format.xml  { render :xml => @fund_items }
    end
  end

  # GET /fund_items/1
  # GET /fund_items/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fund_item }
    end
  end

  # GET /fund_requests/:fund_request_id/fund_items/new
  # GET /fund_requests/:fund_request_id/fund_items/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @fund_item }
    end
  end

  # POST /fund_requests/:fund_request_id/fund_items
  # POST /fund_requests/:fund_request_id/fund_items.xml
  def create
    respond_to do |format|
      if @fund_item.save
        flash[:notice] = 'Fund item was successfully created.'
        format.html { redirect_to polymorphic_url( [ @fund_request, @fund_item ] ) }
        format.xml  { render :xml => @fund_item, :status => :created, :location => @fund_item }
      else
        populate_fund_editions
        format.html { render :action => "new" }
        format.xml  { render :xml => @fund_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /fund_items/1/edit
  def edit
    respond_to do |format|
      format.html { render :action => 'edit' }
    end
  end

  # PUT /fund_items/1
  # PUT /fund_items/1.xml
  def update
    respond_to do |format|
      if @fund_item.save
        flash[:notice] = 'Fund item was successfully updated.'
        format.html { redirect_to polymorphic_url( [ @fund_request, @fund_item ] ) }
        format.xml  { head :ok }
      else
        populate_fund_editions
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @fund_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /fund_items/1
  # DELETE /fund_items/1.xml
  def destroy
    @fund_item.destroy

    respond_to do |format|
      flash[:notice] = 'Fund item was successfully destroyed.'
      format.html { redirect_to @fund_item.fund_grant }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @fund_item = FundItem.find( params[:id], :include => { :fund_editions => :documents } ) if params[:id]
    @fund_request = FundRequest.find params[:fund_request_id] if params[:fund_request_id]
    @fund_grant ||= @fund_item.fund_grant if @fund_item
    @fund_item.attributes = params[:fund_item] if @fund_item && params[:fund_item]
    if @fund_request
      add_breadcrumb @fund_request.fund_grant.organization.name, url_for( @fund_request.fund_grant.organization )
      add_breadcrumb "#{@fund_request.fund_grant.fund_source.name} fund_request", url_for( @fund_request )
      add_breadcrumb 'Items', fund_request_fund_items_path( @fund_request )
    end
  end

  def initialize_index
    @fund_items = @fund_request.fund_items if @fund_request
    @fund_items ||= FundItem.scoped
    @fund_items = @fund_items.ordered
    # No with_permissions scope: Can see items if can see request
  end

  def new_fund_item_from_fund_request
    @fund_item = @fund_request.fund_grant.fund_items.build( params[:fund_item] )
  end

  def populate_fund_editions
    @fund_item.fund_editions.populate_for_fund_request @fund_request
    @fund_item.fund_editions.each { |fund_edition| fund_edition.documents.populate }
  end

  def attach_fund_request_to_new_fund_editions
    @fund_item.fund_editions.each do |fund_edition|
      fund_edition.fund_request = @fund_request if fund_edition.new_record?
    end
  end
end

