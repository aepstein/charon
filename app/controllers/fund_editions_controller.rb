class FundEditionsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  filter_access_to :destroy, attribute_check: true

  # DELETE /fund_items/1
  # DELETE /fund_items/1.xml
  def destroy
    @fund_edition.destroy

    respond_to do |format|
      flash[:notice] = 'Fund item was successfully removed.'
      format.html { redirect_to fund_request_fund_items_path @fund_edition.fund_request }
      format.xml  { head :ok }
    end
  end

  protected

  def initialize_context
    @fund_edition = FundEdition.find params[:id] if params[:id]
  end

end

