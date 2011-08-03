class FundRequestTypesController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_fund_request_type_from_params, :only => [ :new, :create ]
  filter_access_to :show, :destroy, :new, :create, :edit, :update, :attribute_check => true

  # GET /fund_request_types
  # GET /fund_request_types.xml
  def index
    @fund_request_types = @fund_request_types.page(params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fund_request_types }
    end
  end

  # GET /fund_request_types/1
  # GET /fund_request_types/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fund_request_type }
    end
  end

  # GET /fund_request_types/new
  # GET /fund_request_types/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @fund_request_type }
    end
  end

  # GET /fund_request_types/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # POST /fund_request_types
  # POST /fund_request_types.xml
  def create
    respond_to do |format|
      if @fund_request_type.save
        flash[:notice] = 'Fund request type was successfully created.'
        format.html { redirect_to(@fund_request_type) }
        format.xml  { render :xml => @fund_request_type, :status => :created, :location => @fund_request_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fund_request_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /fund_request_types/1
  # PUT /fund_request_types/1.xml
  def update
    respond_to do |format|
      if @fund_request_type.update_attributes(params[:fund_request_type])
        flash[:notice] = 'Fund request type was successfully updated.'
        format.html { redirect_to(@fund_request_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fund_request_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /fund_request_types/1
  # DELETE /fund_request_types/1.xml
  def destroy
    @fund_request_type.destroy

    respond_to do |format|
      format.html { redirect_to(fund_request_types_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @fund_request_type = FundRequestType.find params[:id] if params[:id]
    add_breadcrumb 'Fund request types', fund_request_types_path
  end

  def initialize_index
    @fund_request_types = FundRequestType.scoped
  end

  def new_fund_request_type_from_params
    @fund_request_type = FundRequestType.new( params[:fund_request_type] )
  end
end

