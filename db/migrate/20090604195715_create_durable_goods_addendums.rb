class CreateDurableGoodsAddendums < ActiveRecord::Migration
  def self.up
    create_table :durable_goods_addendums do |t|
      t.string :description
      t.decimal :quantity
      t.decimal :unit_price
      t.decimal :total

      t.timestamps
    end
  end

  def self.down
    drop_table :durable_goods_addendums
  end
end
