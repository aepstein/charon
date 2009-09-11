class FrameworksController < ApplicationController
  before_filter :require_user

  # GET /frameworks
  # GET /frameworks.xml
  def index
    @frameworks = Framework.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @frameworks }
    end
  end

  # GET /frameworks/1
  # GET /frameworks/1.xml
  def show
    @framework = Framework.find(params[:id])
    raise AuthorizationError unless @framework.may_see? current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @framework }
    end
  end

  # GET /frameworks/new
  # GET /frameworks/new.xml
  def new
    @framework = Framework.new
    raise AuthorizationError unless @framework.may_create? current_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @framework }
    end
  end

  # GET /frameworks/1/edit
  def edit
    @framework = Framework.find(params[:id])
    raise AuthorizationError unless @framework.may_update? current_user
  end

  # POST /frameworks
  # POST /frameworks.xml
  def create
    @framework = Framework.new(params[:framework])
    raise AuthorizationError unless @framework.may_create? current_user

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
    @framework = Framework.find(params[:id])
    raise AuthorizationError unless @framework.may_update? current_user

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
    @framework = Framework.find(params[:id])
    raise AuthorizationError unless @framework.may_destroy? current_user
    @framework.destroy

    respond_to do |format|
      format.html { redirect_to(frameworks_url) }
      format.xml  { head :ok }
    end
  end
end

