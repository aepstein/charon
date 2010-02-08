class FulfillmentsController < ApplicationController
  before_filter :initialize_contexts

  # GET /fulfillments
  # GET /fulfillments.xml
  def index
    @fulfillments = @fulfiller.fulfillments if @fulfiller
    @fulfillments = @fulfillable.fulfillments if @fulfillable
    @fulfillments ||= Fulfillment

    @fulfillments = @fulfillments.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fulfillments }
    end
  end

  def initialize_contexts
    @fulfiller = User.find params[:user_id] if params[:user_id]
    @fulfiller = Organization.find params[:organization_id] if params[:organization_id]

    @fulfillable = Agreement.find params[:agreement_id] if params[:agreement_id]
    @fulfillable = RegistrationCriterion.find params[:registration_criterion_id] if params[:registration_criterion_id]
    @fulfillable = UserStatusCriterion.find params[:user_status_criterion_id] if params[:user_status_criterion_id]
  end

end

