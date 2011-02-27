class RegistrationTermsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_registration_term_from_params, :only => [ :new, :create ]
  filter_resource_access

  # GET /registration_terms
  # GET /registration_terms.xml
  def index
    @registration_terms = @registration_terms.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @registration_terms }
    end
  end

  # GET /registration_terms/1
  # GET /registration_terms/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @registration_term }
    end
  end

  # GET /registration_terms/new
  # GET /registration_terms/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @registration_term }
    end
  end

  # GET /registration_terms/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # POST /registration_terms
  # POST /registration_terms.xml
  def create
    respond_to do |format|
      if @registration_term.save
        flash[:notice] = 'Registration term was successfully created.'
        format.html { redirect_to(@registration_term) }
        format.xml  { render :xml => @registration_term, :status => :created, :location => @registration_term }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @registration_term.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /registration_terms/1
  # PUT /registration_terms/1.xml
  def update
    respond_to do |format|
      if @registration_term.update_attributes(params[:registration_term])
        flash[:notice] = 'Registration term was successfully updated.'
        format.html { redirect_to(@registration_term) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @registration_term.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /registration_terms/1
  # DELETE /registration_terms/1.xml
  def destroy
    @registration_term.destroy

    respond_to do |format|
      format.html { redirect_to(registration_terms_url) }
      format.xml  { head :ok }
    end
  end

  private

  def new_registration_term_from_params
    @registration_term = RegistrationTerm.new( params[:registration_term] )
  end

  def initialize_context
    @registration_term = RegistrationTerm.find params[:id] if params[:id]
  end

  def initialize_index
    @registration_terms = RegistrationTerm.scoped
  end
end

