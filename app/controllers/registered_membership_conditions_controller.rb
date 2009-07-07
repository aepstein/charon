class RegisteredMembershipConditionsController < ApplicationController
  # GET /registered_membership_conditions
  # GET /registered_membership_conditions.xml
  def index
    @registered_membership_conditions = RegisteredMembershipCondition.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @registered_membership_conditions }
    end
  end

  # GET /registered_membership_conditions/1
  # GET /registered_membership_conditions/1.xml
  def show
    @registered_membership_condition = RegisteredMembershipCondition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @registered_membership_condition }
    end
  end

  # GET /registered_membership_conditions/new
  # GET /registered_membership_conditions/new.xml
  def new
    @registered_membership_condition = RegisteredMembershipCondition.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @registered_membership_condition }
    end
  end

  # GET /registered_membership_conditions/1/edit
  def edit
    @registered_membership_condition = RegisteredMembershipCondition.find(params[:id])
  end

  # POST /registered_membership_conditions
  # POST /registered_membership_conditions.xml
  def create
    @registered_membership_condition = RegisteredMembershipCondition.new(params[:registered_membership_condition])

    respond_to do |format|
      if @registered_membership_condition.save
        flash[:notice] = 'RegisteredMembershipCondition was successfully created.'
        format.html { redirect_to(@registered_membership_condition) }
        format.xml  { render :xml => @registered_membership_condition, :status => :created, :location => @registered_membership_condition }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @registered_membership_condition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /registered_membership_conditions/1
  # PUT /registered_membership_conditions/1.xml
  def update
    @registered_membership_condition = RegisteredMembershipCondition.find(params[:id])

    respond_to do |format|
      if @registered_membership_condition.update_attributes(params[:registered_membership_condition])
        flash[:notice] = 'RegisteredMembershipCondition was successfully updated.'
        format.html { redirect_to(@registered_membership_condition) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @registered_membership_condition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /registered_membership_conditions/1
  # DELETE /registered_membership_conditions/1.xml
  def destroy
    @registered_membership_condition = RegisteredMembershipCondition.find(params[:id])
    @registered_membership_condition.destroy

    respond_to do |format|
      format.html { redirect_to(registered_membership_conditions_url) }
      format.xml  { head :ok }
    end
  end
end
