class FulfillmentsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_contexts
  filter_access_to :index do
    permitted_to!( :show, @fulfiller ) if @fulfiller
    permitted_to!( :show, @fulfillable ) if @fulfillable
    permitted_to!( :index )
  end

  # GET /fulfillments
  # GET /fulfillments.xml
  def index
    @fulfillments = @context.fulfillments if @context
    @fulfillments ||= Fulfillment.scoped

    @fulfillments = @fulfillments.with_permissions_to(:show).paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fulfillments }
    end
  end

  private

  def initialize_contexts
    @fulfiller = User.find params[:user_id] if params[:user_id]
    @fulfiller = Organization.find params[:organization_id] if params[:organization_id]

    @fulfillable = Agreement.find params[:agreement_id] if params[:agreement_id]
    @fulfillable = RegistrationCriterion.find params[:registration_criterion_id] if params[:registration_criterion_id]
    @fulfillable = UserStatusCriterion.find params[:user_status_criterion_id] if params[:user_status_criterion_id]

    @context = @fulfiller || @fulfillable
    if @context
      add_breadcrumb @context, url_for( @context )
      add_breadcrumb 'Fulfillments', polymorphic_path( [ @context, :fulfillments ] )
    end
  end

end

