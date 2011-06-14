class BasesController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_basis_from_params, :only => [ :new, :create ]
  filter_access_to :show, :edit, :update, :new, :create, :destroy, :attribute_check => true
  filter_access_to :index do
    permitted_to!( :show, @organization )
  end

  # GET /organizations/:organization_id/bases
  # GET /organizations/:organization_id/bases.xml
  def index
    @search = @bases.search( params[:search] )
    @bases = @search.paginate( :page => params[:page] )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bases }
    end
  end

  # GET /bases/1
  # GET /bases/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @basis }
    end
  end

  # GET /organizations/:organization_id/bases/new
  # GET /organizations/:organization_id/bases/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @basis }
    end
  end

  # GET /bases/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # POST /organizations/:organization_id/bases
  # POST /organizations/:organization_id/bases.xml
  def create
    respond_to do |format|
      if @basis.save
        flash[:notice] = 'Basis was successfully created.'
        format.html { redirect_to(@basis) }
        format.xml  { render :xml => @basis, :status => :created, :location => @basis }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @basis.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bases/1
  # PUT /bases/1.xml
  def update
    respond_to do |format|
      if @basis.update_attributes(params[:basis])
        flash[:notice] = 'Basis was successfully updated.'
        format.html { redirect_to(@basis) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @basis.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bases/1
  # DELETE /bases/1.xml
  def destroy
    @basis.destroy

    respond_to do |format|
      flash[:notice] = 'Basis was successfully destroyed.'
      format.html { redirect_to(organization_bases_url(@basis.organization)) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @basis = Basis.find params[:id] if params[:id]
    @organization = Organization.find params[:organization_id] if params[:organization_id]
  end

  def initialize_index
    @bases = @organization.bases.with_permissions_to(:show)
  end

  def new_basis_from_params
    @basis = @organization.bases.build( params[:basis] )
  end
end

