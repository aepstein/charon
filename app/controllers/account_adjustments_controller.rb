class AccountAdjustmentsController < ApplicationController
  # GET /account_adjustments
  # GET /account_adjustments.xml
  def index
    @account_adjustments = AccountAdjustment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @account_adjustments }
    end
  end

  # GET /account_adjustments/1
  # GET /account_adjustments/1.xml
  def show
    @account_adjustment = AccountAdjustment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account_adjustment }
    end
  end

  # GET /account_adjustments/new
  # GET /account_adjustments/new.xml
  def new
    @account_adjustment = AccountAdjustment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account_adjustment }
    end
  end

  # GET /account_adjustments/1/edit
  def edit
    @account_adjustment = AccountAdjustment.find(params[:id])
  end

  # POST /account_adjustments
  # POST /account_adjustments.xml
  def create
    @account_adjustment = AccountAdjustment.new(params[:account_adjustment])

    respond_to do |format|
      if @account_adjustment.save
        format.html { redirect_to(@account_adjustment, :notice => 'Account adjustment was successfully created.') }
        format.xml  { render :xml => @account_adjustment, :status => :created, :location => @account_adjustment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @account_adjustment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /account_adjustments/1
  # PUT /account_adjustments/1.xml
  def update
    @account_adjustment = AccountAdjustment.find(params[:id])

    respond_to do |format|
      if @account_adjustment.update_attributes(params[:account_adjustment])
        format.html { redirect_to(@account_adjustment, :notice => 'Account adjustment was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account_adjustment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /account_adjustments/1
  # DELETE /account_adjustments/1.xml
  def destroy
    @account_adjustment = AccountAdjustment.find(params[:id])
    @account_adjustment.destroy

    respond_to do |format|
      format.html { redirect_to(account_adjustments_url) }
      format.xml  { head :ok }
    end
  end
end
