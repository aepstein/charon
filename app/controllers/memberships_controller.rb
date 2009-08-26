class MembershipsController < ApplicationController
  # GET /organizations/:organization_id/memberships
  # GET /organizations/:organization_id/memberships.xml
  def index
    @organization = Organization.find(params[:organization_id])
    raise AuthorizationError unless @organization.may_see? current_user
    @memberships = @organization.memberships

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @memberships }
    end
  end

  # GET /memberships/1
  # GET /memberships/1.xml
  def show
    @membership = Membership.find(params[:id])
    raise AuthorizationError unless @membership.may_see? current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @membership }
    end
  end

  # GET /organizations/:organization_id/memberships/new
  # GET /organizations/:organization_id/memberships/new.xml
  def new
    @membership = Organization.find(params[:organization_id]).memberships.build
    raise AuthorizationError unless @membership.may_create? current_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @membership }
    end
  end

  # GET /memberships/1/edit
  def edit
    @membership = Membership.find(params[:id])
    raise AuthorizationError unless @membership.may_update? current_user
  end

  # POST /organizations/:organization_id/memberships
  # POST /organizations/:organization_id/memberships.xml
  def create
    @membership = Organization.find(params[:organization_id]).memberships.build(params[:membership])
    raise AuthorizationError unless @membership.may_create? current_user

    respond_to do |format|
      if @membership.save
        flash[:notice] = 'Membership was successfully created.'
        format.html { redirect_to(@membership) }
        format.xml  { render :xml => @membership, :status => :created, :location => @membership }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @membership.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /memberships/1
  # PUT /memberships/1.xml
  def update
    @membership = Membership.find(params[:id])
    raise AuthorizationError unless @membership.may_update? current_user

    respond_to do |format|
      if @membership.update_attributes(params[:membership])
        flash[:notice] = 'Membership was successfully updated.'
        format.html { redirect_to(@membership) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @membership.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /memberships/1
  # DELETE /memberships/1.xml
  def destroy
    @membership = Membership.find(params[:id])
    raise AuthorizationError unless @membership.may_destroy? current_user
    @membership.destroy

    respond_to do |format|
      format.html { redirect_to(memberships_url) }
      format.xml  { head :ok }
    end
  end
end

