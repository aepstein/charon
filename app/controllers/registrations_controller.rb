class RegistrationsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  filter_access_to :show, :attribute_check => true

  def index
    @registrations = @registrations.with_permissions_to(:show)
    @search = @registrations.searchlogic( params[:search] )
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
  end

  def initialize_index
    @registrations = Registration
  end
end

