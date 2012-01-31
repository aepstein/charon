class AddInstructionToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :instruction, :text
  end
end

