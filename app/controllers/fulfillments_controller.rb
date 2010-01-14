class FulfillmentsController < ApplicationController
  # GET /fulfillments
  # GET /fulfillments.xml
  def index
    @fulfillments = Fulfillment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fulfillments }
    end
  end

end

