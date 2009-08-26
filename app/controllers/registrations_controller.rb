class RegistrationsController < ApplicationController

  def index
    page = params[:page] ? params[:page] : 1
    if params[:search]
      @registrations = Registration.name_like("%#{params[:search][:q]}%").paginate(:page => page)
    else
      @registrations = Registration.paginate(:page => page)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @registrations }
    end
  end

  def show
    @registration = Registration.find( params[:id], :include => :organization )
    raise AuthorizationError unless @registration.may_see? current_user
  end
end

