class FundTierAssignmentsController < ApplicationController
  before_filter :require_user
  expose :fund_source
  expose :fund_tier_assignments, ancestor: :fund_source
  expose :fund_tier_assignment
  filter_access_to :index do
    permitted_to! :lead, fund_source if fund_source
  end
  filter_access_to :create, :update, load_method: :fund_tier_assignment,
    attribute_check: true

  def index

  end

  def create
    respond_to do |format|
      if fund_tier_assignment.save
        format.html { redirect_to fund_source_fund_tier_assignments_url( fund_source ),
          notice: "Fund tier assignment successfully created." }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: fund_tier_assignment.errors, status: :unprocessable_entity  }
      end
    end
  end

  def update
    respond_to do |format|
      if fund_tier_assignment.update_attributes( params[:fund_tier_assignment] )
        format.html { redirect_to fund_source_fund_tier_assignments_url( fund_source ),
          notice: "Fund allocation assignment successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: fund_tier_assignment.errors, status: :unprocessable_entity  }
      end
    end
  end
end

