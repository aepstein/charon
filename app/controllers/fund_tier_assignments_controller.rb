class FundTierAssignmentsController < ApplicationController
  before_filter :require_user
  expose :fund_tier_assignment
  expose( :fund_tier_assignments ) { fund_source.fund_tier_assignments.scoped.page( params[:page] ) }
  expose( :fund_source ) { params[:fund_source_id] ? FundSource.find(params[:fund_source_id]) : nil }
  filter_access_to :index do
    permitted_to! :lead, fund_source if fund_source
  end
  filter_access_to :update, load_method: :fund_tier_assignment,
    attribute_check: true

  def index

  end

  def update
    respond_to do |format|
      if fund_allocation_assignment.update_attributes( params[:fund_allocation_assignment] )
        format.html { redirect_to fund_source_fund_allocation_assignments_url( fund_source ),
          notice: "Fund allocation assignment successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: schedule.errors, status: :unprocessable_entity  }
      end
    end
  end
end

