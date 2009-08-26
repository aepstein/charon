class RegistrationsController < ApplicationController

  def index
    @registrations = Registration.search( params[:query] )
    flash[:message] = "There were no registrations matching <em>#{params[:query]}</em>. " if @registrations.empty?
    redirect_to registration_path(@registrations.first) if @registrations.size == 1
  end

  def show
    @registration = Registration.find( params[:id], :include => :organization )
    raise AuthorizationError unless @registration.may_see? current_user
  end
end

