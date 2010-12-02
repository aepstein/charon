class RegistrationsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  filter_access_to :show, :attribute_check => true

  def index
    @registrations = @registrations.with_permissions_to(:show)
    @search = @registrations.search( params[:search] )
    @registrations = @search.paginate( :page => params[:page] )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @registrations }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @registration }
    end
  end

  private

  def initialize_context
    @registration = Registration.find params[:id] if params[:id]
    @organization = Organization.find params[:organization_id] if params[:organization_id]
    @registration_term = RegistrationTerm.find params[:registration_term_id] if params[:registration_term_id]
  end

  def initialize_index
    @registrations = Registration.scoped( :conditions => { :organization_id => @organization.id } ) if @organization
    @registrations = Registration.scoped( :conditions => { :registration_term_id => @registration_term.id } ) if @registration_term
    @registrations ||= Registration
  end
end

