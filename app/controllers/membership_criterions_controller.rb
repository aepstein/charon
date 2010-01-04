class MembershipCriterionsController < ApplicationController
  # GET /membership_criterions
  # GET /membership_criterions.xml
  def index
    @membership_criterions = MembershipCriterion.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @membership_criterions }
    end
  end

  # GET /membership_criterions/1
  # GET /membership_criterions/1.xml
  def show
    @membership_criterion = MembershipCriterion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @membership_criterion }
    end
  end

  # GET /membership_criterions/new
  # GET /membership_criterions/new.xml
  def new
    @membership_criterion = MembershipCriterion.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @membership_criterion }
    end
  end

  # GET /membership_criterions/1/edit
  def edit
    @membership_criterion = MembershipCriterion.find(params[:id])
  end

  # POST /membership_criterions
  # POST /membership_criterions.xml
  def create
    @membership_criterion = MembershipCriterion.new(params[:membership_criterion])

    respond_to do |format|
      if @membership_criterion.save
        flash[:notice] = 'MembershipCriterion was successfully created.'
        format.html { redirect_to(@membership_criterion) }
        format.xml  { render :xml => @membership_criterion, :status => :created, :location => @membership_criterion }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @membership_criterion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /membership_criterions/1
  # PUT /membership_criterions/1.xml
  def update
    @membership_criterion = MembershipCriterion.find(params[:id])

    respond_to do |format|
      if @membership_criterion.update_attributes(params[:membership_criterion])
        flash[:notice] = 'MembershipCriterion was successfully updated.'
        format.html { redirect_to(@membership_criterion) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @membership_criterion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /membership_criterions/1
  # DELETE /membership_criterions/1.xml
  def destroy
    @membership_criterion = MembershipCriterion.find(params[:id])
    @membership_criterion.destroy

    respond_to do |format|
      format.html { redirect_to(membership_criterions_url) }
      format.xml  { head :ok }
    end
  end
end
