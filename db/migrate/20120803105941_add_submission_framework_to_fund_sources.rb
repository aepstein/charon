class AddSubmissionFrameworkToFundSources < ActiveRecord::Migration
  class FundSource < ActiveRecord::Base
  end

  def up
    add_column :fund_sources, :submission_framework_id, :integer
    FundSource.reset_column_information
    FundSource.update_all( "submission_framework_id = framework_id" )
    change_column :fund_sources, :submission_framework_id, :integer, null: false
  end

  def down
    remove_column :fund_sources, :submission_framework_id
  end
end

