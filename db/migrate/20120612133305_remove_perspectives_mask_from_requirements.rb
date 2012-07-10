class RemovePerspectivesMaskFromRequirements < ActiveRecord::Migration
  def up
    remove_column :requirements, :perspectives_mask
  end

  def down
    add_column :requirements, :perspectives_mask, :integer, null: false, default: 0
  end
end

