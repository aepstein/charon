class RemoveFundTierIdFromFundGrants < ActiveRecord::Migration
  def up
    execute <<-SQL
      INSERT INTO fund_tier_assignments ( fund_source_id, organization_id,
      fund_tier_id, created_at, updated_at )
      SELECT fund_source_id, organization_id, fund_tier_id, created_at,
      updated_at FROM fund_grants WHERE fund_tier_id IS NOT NULL
    SQL
    execute <<-SQL
      UPDATE fund_grants SET fund_tier_assignment_id = (
      SELECT id FROM fund_tier_assignments WHERE
      fund_source_id = fund_grants.fund_source_id AND
      organization_id = fund_grants.organization_id
      )
    SQL
    remove_index :fund_grants, :fund_tier_id
    remove_column :fund_grants, :fund_tier_id
  end

  def down
    add_column :fund_grants, :fund_tier_id, :integer
  end
end

