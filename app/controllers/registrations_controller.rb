class RegistrationsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  filter_access_to :show, :attribute_check => true

  def index
    @search = params[:search] || Hash.new
    @search.each do |k,v|
      if !v.blank? && Registration::SEARCHABLE.include?( k.to_sym )
        @registrations = @registrations.send k, v
      end
    end
    @registrations = @registrations.page( params[:page] )

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
    if @registration
      @organization ||= @registration.organization
      @registration_term ||= @registration.registration_term
    end
    @context = @organization || @registration_term
    add_breadcrumb 'Registration terms', registration_terms_path
    if @context
      add_breadcrumb @context, url_for( @context )
      add_breadcrumb 'Registrations', polymorphic_path( [ @context, :registrations ] )
    end
  end

  def initialize_index
    @registrations = Registration.scoped
    if @organization
      @registrations = @registrations.where( :organization_id => @organization.id )
    end
    if @registration_term
      @registrations = @registrations.where( :registration_term_id => @registration_term.id )
    end
    @registrations = @registrations.with_permissions_to( :show )
  end
end

