class CreateAgreements < ActiveRecord::Migration
  def self.up
    create_table :agreements do |t|
      t.string :name, :null => false
      t.text :content, :null => false

      t.timestamps
    end
    add_index :agreements, :name, :unique => true
  end

  def self.down
    drop_table :agreements
  end
end

