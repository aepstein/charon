class RenameExternalEquityReportsToOrganizationProfiles < ActiveRecord::Migration
  class Node < ActiveRecord::Base
    has_many :fund_items, :inverse_of => :node, :dependent => :destroy
    has_ancestry :orphan_strategy => :restrict
  end

  class FundItem < ActiveRecord::Base
    belongs_to :node, :inverse_of => :fund_items
    has_many :fund_editions, :dependent => :destroy
    acts_as_list :scope => [ :fund_grant_id ]
    has_ancestry :orphan_strategy => :restrict
  end

  class FundEdition < ActiveRecord::Base
    belongs_to :fund_item
    has_many :documents, :dependent => :destroy
  end

  class Document < ActiveRecord::Base
    belongs_to :fund_edition
  end

  class OrganizationProfile < ActiveRecord::Base
  end

  def up
    create_table :organization_profiles do |t|
      t.integer  "organization_id", :null => false
      t.decimal  "anticipated_expenses", :precision => 13, :scale => 2, :default => 0.0, :null => false
      t.decimal  "anticipated_income", :precision => 13, :scale => 2, :default => 0.0, :null => false
      t.decimal  "current_assets", :precision => 13, :scale => 2, :default => 0.0, :null => false
      t.decimal  "current_liabilities", :precision => 13, :scale => 2, :default => 0.0, :null => false
      t.boolean  "academic_credit"
      t.timestamps
    end
    add_index :organization_profiles, :organization_id, :unique => true
    say_with_time 'Associating profiles with organizations and culling old versions' do
      OrganizationProfile.reset_column_information
      OrganizationProfile.connection.execute <<-SQL
        INSERT INTO organization_profiles ( anticipated_expenses,
        anticipated_income, current_assets, current_liabilities, academic_credit,
        organization_id, created_at, updated_at )
        SELECT anticipated_expenses, anticipated_income, current_assets,
        current_liabilities, academic_credit, organization_id,
        fund_editions.created_at, fund_editions.updated_at
        FROM fund_grants INNER JOIN fund_requests ON fund_grants.id = fund_requests.fund_grant_id
        INNER JOIN fund_editions ON fund_requests.id = fund_editions.fund_request_id
        INNER JOIN external_equity_reports ON fund_editions.id = external_equity_reports.fund_edition_id
        GROUP BY fund_grants.organization_id
        ORDER BY fund_editions.created_at DESC
      SQL
    end
    say_with_time 'Removing nodes and items associated with external equity reports' do
      FundItem.joins(:node).where( 'nodes.requestable_type = ?', 'ExternalEquityReport' ).each do |item|
        item.children.each { |child| child.parent = item.parent; child.save! }
      end
      Node.where( :requestable_type => 'ExternalEquityReport' ).each do |node|
        node.children.each { |child| child.parent = node.parent; child.save! }
        node.destroy
      end
    end
    remove_index :external_equity_reports, :fund_edition_id
    drop_table :external_equity_reports
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

