class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name

      t.timestamps
    end
    default_category = Category.create(:name => 'Default Category')
    add_column :nodes, :category_id, :integer, { :default => default_category.id, :null => false }
    update_column :nodes, :category_id, :integer, { :null => false, :default => nil } if defined?(update_column)
    add_index :nodes, :category_id
    add_index :categories, :name, :unique => true
  end

  def self.down
    remove_column :nodes, :category_id
    drop_table :categories
  end
end

