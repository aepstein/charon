class BasesController < ApplicationController
  # GET /organizations/:organization_id/bases
  # GET /organizations/:organization_id/bases.xml
  def index
    @organization = Organization.find(params[:organization_id])
    @bases = @organization.bases

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bases }
    end
  end

  # GET /bases/1
  # GET /bases/1.xml
  def show
    @basis = Basis.find(params[:id])
    raise AuthorizationError unless @basis.may_see? current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @basis }
    end
  end

  # GET /organizations/:organization_id/bases/new
  # GET /organizations/:organization_id/bases/new.xml
  def new
    @basis = Organization.find(params[:organization_id]).bases.build
    raise AuthorizationError unless @basis.may_create? current_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @basis }
    end
  end

  # GET /bases/1/edit
  def edit
    @basis = Basis.find(params[:id])
    raise AuthorizationError unless @basis.may_update? current_user
  end

  # POST /organizations/:organization_id/bases
  # POST /organizations/:organization_id/bases.xml
  def create
    @basis = Organization.find(params[:organization_id]).bases.build(params[:basis])
    raise AuthorizationError unless @basis.may_create? current_user

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
    @basis = Basis.find(params[:id])
    raise AuthorizationError unless @basis.may_update? current_user

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
    @basis = Basis.find(params[:id])
    raise AuthorizationError unless @basis.may_destroy? current_user
    @basis.destroy

    respond_to do |format|
      flash[:notice] = 'Basis was successfully destroyed.'
      format.html { redirect_to(organization_bases_url(@basis.organization)) }
      format.xml  { head :ok }
    end
  end
end

