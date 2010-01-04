class AgreementCriterionsController < ApplicationController
  # GET /agreement_criterions
  # GET /agreement_criterions.xml
  def index
    @agreement_criterions = AgreementCriterion.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @agreement_criterions }
    end
  end

  # GET /agreement_criterions/1
  # GET /agreement_criterions/1.xml
  def show
    @agreement_criterion = AgreementCriterion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @agreement_criterion }
    end
  end

  # GET /agreement_criterions/new
  # GET /agreement_criterions/new.xml
  def new
    @agreement_criterion = AgreementCriterion.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @agreement_criterion }
    end
  end

  # GET /agreement_criterions/1/edit
  def edit
    @agreement_criterion = AgreementCriterion.find(params[:id])
  end

  # POST /agreement_criterions
  # POST /agreement_criterions.xml
  def create
    @agreement_criterion = AgreementCriterion.new(params[:agreement_criterion])

    respond_to do |format|
      if @agreement_criterion.save
        flash[:notice] = 'AgreementCriterion was successfully created.'
        format.html { redirect_to(@agreement_criterion) }
        format.xml  { render :xml => @agreement_criterion, :status => :created, :location => @agreement_criterion }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @agreement_criterion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /agreement_criterions/1
  # PUT /agreement_criterions/1.xml
  def update
    @agreement_criterion = AgreementCriterion.find(params[:id])

    respond_to do |format|
      if @agreement_criterion.update_attributes(params[:agreement_criterion])
        flash[:notice] = 'AgreementCriterion was successfully updated.'
        format.html { redirect_to(@agreement_criterion) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @agreement_criterion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /agreement_criterions/1
  # DELETE /agreement_criterions/1.xml
  def destroy
    @agreement_criterion = AgreementCriterion.find(params[:id])
    @agreement_criterion.destroy

    respond_to do |format|
      format.html { redirect_to(agreement_criterions_url) }
      format.xml  { head :ok }
    end
  end
end
