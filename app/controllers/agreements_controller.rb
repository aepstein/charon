class AgreementsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_agreement_from_params, :only => [ :new, :create ]
  filter_resource_access

  # GET /agreements
  # GET /agreements.xml
  def index
    @agreements = @agreements.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @agreements }
    end
  end

  # GET /agreements/1
  # GET /agreements/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @agreement }
    end
  end

  # GET /agreements/new
  # GET /agreements/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @agreement }
    end
  end

  # GET /agreements/1/edit
  def edit
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /agreements
  # POST /agreements.xml
  def create
    respond_to do |format|
      if @agreement.save
        flash[:notice] = 'Agreement was successfully created.'
        format.html { redirect_to(@agreement) }
        format.xml  { render :xml => @agreement, :status => :created, :location => @agreement }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @agreement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /agreements/1
  # PUT /agreements/1.xml
  def update
    respond_to do |format|
      if @agreement.update_attributes(params[:agreement])
        flash[:notice] = 'Agreement was successfully updated.'
        format.html { redirect_to(@agreement) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @agreement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /agreements/1
  # DELETE /agreements/1.xml
  def destroy
    @agreement.destroy

    respond_to do |format|
      format.html { redirect_to(agreements_url) }
      format.xml  { head :ok }
    end
  end

  private

  def new_agreement_from_params
    @agreement = Agreement.new( params[:agreement] )
  end

  def initialize_context
    @agreement = Agreement.find params[:id] if params[:id]
  end

  def initialize_index
    @agreements = Agreement
  end
end

