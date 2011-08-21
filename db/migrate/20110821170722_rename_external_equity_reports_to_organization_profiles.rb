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
    remove_index :external_equity_reports, :fund_edition_id
    rename_table :external_equity_reports, :organization_profiles
    add_column :organization_profiles, :organization_id, :integer
    say_with_time 'Associating profiles with organizations and culling old versions' do
      OrganizationProfile.reset_column_information
      OrganizationProfile.update_all( 'organization_id = ' +
        '( SELECT organization_id FROM fund_grants INNER JOIN fund_requests ON ' +
        '  fund_grants.id = fund_requests.fund_grant_id INNER JOIN fund_editions ' +
        '  ON fund_requests.id = fund_editions.fund_request_id ' +
        '  WHERE fund_editions.id = organization_profiles.fund_edition_id ) ' )
      change_column :organization_profiles, :organization_id, :integer, :null => false
      OrganizationProfile.reset_column_information
      OrganizationProfile.group('organization_id').having('updated_at < MAX(updated_at)').delete_all
      add_index :organization_profiles, :organization_id, :unique => true
      remove_column :organization_profiles, :fund_edition_id
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
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

