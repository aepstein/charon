class FundQueuesController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  filter_access_to :show, :attribute_check => true

  # GET /fund_grants/1
  # GET /fund_grants/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fund_grant }
    end
  end

  private

  def initialize_context
    @fund_queue = FundQueue.find params[:id] if params[:id]
  end

end

