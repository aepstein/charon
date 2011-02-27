class FrameworksController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_framework_from_params, :only => [ :new, :create ]
  filter_access_to :show, :new, :create, :destroy, :edit, :update, :attribute_check => true

  # GET /frameworks
  # GET /frameworks.xml
  def index
    @frameworks = @frameworks.paginate( :page => params[:page] )
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @frameworks }
    end
  end

  # GET /frameworks/1
  # GET /frameworks/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @framework }
    end
  end

  # GET /frameworks/new
  # GET /frameworks/new.xml
  def new
    @framework.requirements.build
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @framework }
    end
  end

  # GET /frameworks/1/edit
  def edit
    @framework.requirements.build
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # POST /frameworks
  # POST /frameworks.xml
  def create
    respond_to do |format|
      if @framework.save
        flash[:notice] = 'Framework was successfully created.'
        format.html { redirect_to(@framework) }
        format.xml  { render :xml => @framework, :status => :created, :location => @framework }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @framework.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /frameworks/1
  # PUT /frameworks/1.xml
  def update
    respond_to do |format|
      if @framework.update_attributes(params[:framework])
        flash[:notice] = 'Framework was successfully updated.'
        format.html { redirect_to(@framework) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @framework.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /frameworks/1
  # DELETE /frameworks/1.xml
  def destroy
    @framework.destroy

    respond_to do |format|
      format.html { redirect_to(frameworks_url) }
      format.xml  { head :ok }
    end
  end

  def initialize_context
    @framework = Framework.find params[:id] if params[:id]
  end

  def initialize_index
    @frameworks = Framework.scoped
  end

  def new_framework_from_params
    @framework = Framework.new( params[:framework] )
  end
end

