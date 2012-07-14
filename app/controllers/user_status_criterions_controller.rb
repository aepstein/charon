class UserStatusCriterionsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, only: [ :index ]
  before_filter :new_user_status_criterion_from_params, only: [ :new, :create ]
  filter_resource_access

  # GET /user_status_criterions
  # GET /user_status_criterions.xml
  def index
    @user_status_criterions = @user_status_criterions.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_status_criterions }
    end
  end

  # GET /user_status_criterions/1
  # GET /user_status_criterions/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_status_criterion }
    end
  end

  # GET /user_status_criterions/new
  # GET /user_status_criterions/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_status_criterion }
    end
  end

  # GET /user_status_criterions/1/edit
  def edit
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /user_status_criterions
  # POST /user_status_criterions.xml
  def create
    respond_to do |format|
      if @user_status_criterion.save
        flash[:notice] = 'User status criterion was successfully created.'
        format.html { redirect_to(@user_status_criterion) }
        format.xml  { render :xml => @user_status_criterion, :status => :created, :location => @user_status_criterion }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_status_criterion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_status_criterions/1
  # PUT /user_status_criterions/1.xml
  def update
    respond_to do |format|
      if @user_status_criterion.update_attributes(params[:user_status_criterion])
        flash[:notice] = 'User status criterion was successfully updated.'
        format.html { redirect_to(@user_status_criterion) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_status_criterion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_status_criterions/1
  # DELETE /user_status_criterions/1.xml
  def destroy
    @user_status_criterion.destroy

    respond_to do |format|
      format.html { redirect_to(user_status_criterions_url) }
      format.xml  { head :ok }
    end
  end

  private

  def new_user_status_criterion_from_params
    @user_status_criterion = UserStatusCriterion.new( params[:user_status_criterion] )
  end

  def initialize_context
    @user_status_criterion = UserStatusCriterion.find params[:id] if params[:id]
    add_breadcrumb 'User Status Criterions', user_status_criterions_path
  end

  def initialize_index
    @user_status_criterions = UserStatusCriterion.scoped
  end
end

