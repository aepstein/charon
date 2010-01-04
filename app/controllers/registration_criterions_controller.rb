class RegistrationCriterionsController < ApplicationController
  # GET /registration_criterions
  # GET /registration_criterions.xml
  def index
    @registration_criterions = RegistrationCriterion.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @registration_criterions }
    end
  end

  # GET /registration_criterions/1
  # GET /registration_criterions/1.xml
  def show
    @registration_criterion = RegistrationCriterion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @registration_criterion }
    end
  end

  # GET /registration_criterions/new
  # GET /registration_criterions/new.xml
  def new
    @registration_criterion = RegistrationCriterion.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @registration_criterion }
    end
  end

  # GET /registration_criterions/1/edit
  def edit
    @registration_criterion = RegistrationCriterion.find(params[:id])
  end

  # POST /registration_criterions
  # POST /registration_criterions.xml
  def create
    @registration_criterion = RegistrationCriterion.new(params[:registration_criterion])

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
    @registration_criterion = RegistrationCriterion.find(params[:id])

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
    @registration_criterion = RegistrationCriterion.find(params[:id])
    @registration_criterion.destroy

    respond_to do |format|
      format.html { redirect_to(registration_criterions_url) }
      format.xml  { head :ok }
    end
  end
end
