class FundTierAssignmentsController < ApplicationController
  before_filter :require_user
  expose :fund_source
  expose :fund_tier_assignment do
    a = params[:id] ? FundTierAssignment.find(params[:id]) : fund_source.fund_tier_assignments.build
    a.assign_attributes params[:fund_tier_assignment] if params[:fund_tier_assignment]
    a
  end
  expose( :fund_tier_assignments ) { fund_source.fund_tier_assignments.ordered.page(params[:page]) }
  filter_access_to [ :new, :create, :update, :destroy ],
    load_method: :fund_tier_assignment, attribute_check: true
  filter_access_to [ :index ] do
    permitted_to! :review, fund_source if fund_source
  end

  # GET /fund_tier_assignments
  # GET /fund_tier_assignments.json
  def index
    @search = params[:search] || Hash.new
    @search.each do |k,v|
      if !v.blank? && FundTierAssignment::SEARCHABLE.include?( k.to_sym )
        self.fund_tier_assignments = fund_tier_assignments.send k, v
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: fund_tier_assignments }
    end
  end

  # POST /fund_tier_assignments
  # POST /fund_tier_assignments.json
  def create
    respond_to do |format|
      if fund_tier_assignment.save
        format.html { redirect_to fund_source_fund_tier_assignments_url( fund_source ),
          notice: 'Fund tier assignment was successfully created.' }
        format.json { render json: fund_tier_assignment, status: :created, location: fund_tier_assignment }
      else
        format.html { render action: "new" }
        format.json { render json: fund_tier_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /fund_tier_assignments/1
  # PUT /fund_tier_assignments/1.json
  def update
    respond_to do |format|
      if fund_tier_assignment.update_attributes(params[:fund_tier_assignment])
        format.html { redirect_to fund_source_fund_tier_assignments_url( fund_tier_assignment.fund_source ),
          notice: 'Fund tier assignment was successfully updated.' }
        format.json { respond_with_bip(fund_tier_assignment) }
      else
        format.html { render action: "edit" }
        format.json { respond_with_bip(fund_tier_assignment) }
      end
    end
  end

  # DELETE /fund_tier_assignments/1
  # DELETE /fund_tier_assignments/1.json
  def destroy
    fund_tier_assignment.destroy

    respond_to do |format|
      format.html { redirect_to fund_source_fund_tier_assignments_url( fund_tier_assignment.fund_source ),
        notice: 'Fund tier assignment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
end

