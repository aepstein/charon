class RegistrationCriterionsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_registration_criterion_from_params, :only => [ :new, :create ]
  filter_access_to :show, :new, :create, :edit, :update, :destroy, :attribute_check => true

  # GET /registration_criterions
  # GET /registration_criterions.xml
  def index
    @registration_criterions = @registration_criterions.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @registration_criterions }
    end
  end

  # GET /registration_criterions/1
  # GET /registration_criterions/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @registration_criterion }
    end
  end

  # GET /registration_criterions/new
  # GET /registration_criterions/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @registration_criterion }
    end
  end

  # GET /registration_criterions/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # POST /registration_criterions
  # POST /registration_criterions.xml
  def create
    respond_to do |format|
      if @registration_criterion.save
        flash[:notice] = 'RegistrationCriterion was successfully created.'
        format.html { redirect_to(@registration_criterion) }
        format.xml  { render :xml => @registration_criterion, :status => :created, :location => @registration_criterion }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @registration_criterion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /registration_criterions/1
  # PUT /registration_criterions/1.xml
  def update
    respond_to do |format|
      if @registration_criterion.update_attributes(params[:registration_criterion])
        flash[:notice] = 'RegistrationCriterion was successfully updated.'
        format.html { redirect_to(@registration_criterion) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @registration_criterion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /registration_criterions/1
  # DELETE /registration_criterions/1.xml
  def destroy
    @registration_criterion.destroy

    respond_to do |format|
      format.html { redirect_to(registration_criterions_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @registration_criterion = RegistrationCriterion.find params[:id] if params[:id]
    add_breadcrumb 'Registration criterions', registration_criterions_path
  end

  def initialize_index
    @registration_criterions = RegistrationCriterion.scoped
  end

  def new_registration_criterion_from_params
    @registration_criterion = RegistrationCriterion.new( params[:registration_criterion] )
  end
end

