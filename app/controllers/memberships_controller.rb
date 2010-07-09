class MembershipsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_membership_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :attribute_check => true

  # GET /organizations/:organization_id/memberships
  # GET /organizations/:organization_id/memberships.xml
  def index
    @search = @memberships.searchlogic( params[:search] )
    @memberships = @search.paginate( :page => params[:page] )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @memberships }
    end
  end

  # GET /memberships/1
  # GET /memberships/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @membership }
    end
  end

  # GET /organizations/:organization_id/memberships/new
  # GET /organizations/:organization_id/memberships/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @membership }
    end
  end

  # GET /memberships/1/edit
  def edit
    # edit.html.erb
  end

  # POST /organizations/:organization_id/memberships
  # POST /organizations/:organization_id/memberships.xml
  def create
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
    @membership.destroy

    respond_to do |format|
      format.html { redirect_to user_memberships_url @membership.user }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @membership = Membership.find params[:id] if params[:id]
    @context = Organization.find params[:organization_id] if params[:organization_id]
    @context = User.find params[:user_id] if params[:user_id]
  end

  def initialize_index
    @memberships = Membership
    @memberships = @memberships.scoped( :conditions => { :organization_id => @context.id } ) if @context && @context.class == Organization
    @memberships = @memberships.scoped( :conditions => { :user_id => @context.id } ) if @context && @context.class == User
  end

  def new_membership_from_params
    @membership = @context.memberships.build( params[:membership] ) if @context
  end
end

