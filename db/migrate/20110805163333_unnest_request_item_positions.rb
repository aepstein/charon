class UnnestRequestItemPositions < ActiveRecord::Migration
  class FundGrant < ActiveRecord::Base
    has_many :fund_items, :inverse_of => :fund_grant
  end

  class FundItem < ActiveRecord::Base
    belongs_to :fund_grant, :inverse_of => :fund_items
    has_ancestry
    default_scope order { position }
  end

  def self.up
    say_with_time 'Converting fund items to unnested lists' do
      FundGrant.find_in_batches do |grants|
        grants.each { |grant| recurse_up 1, grant.fund_items.roots }
      end
    end
    add_index :fund_items, [ :fund_grant_id, :position ], :unique => true
  end

  def self.recurse_up(position, items)
    items.each do |item|
      item.update_attribute :position, position
      position += 1
      position = recurse_up( position, item.children )
    end
    position
  end

  def self.down
    remove_index :fund_items, [ :fund_grant_id, :position ]
    say_with_time 'Converting fund items to nested lists' do
      FundGrant.find_in_batches do |grants|
        grants.each { |grant| recurse_down grant.fund_items.roots }
      end
    end
  end

  def self.recurse_down(items)
    position = 1
    items.each do |item|
      item.update_attribute :position, position
      position += 1
      recurse_down item.children
    end
  end
end

