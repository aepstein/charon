require 'spec_helper'

describe FundItem do
  let( :fund_item ) { build(:fund_item) }

  it "should save with valid attributes" do
    fund_item.save!
  end

  it "should set its title from the node" do
    fund_item.save!
    fund_item.title.should eql fund_item.node.name
  end

  it "should call fund_grant.touch on save" do
    fund_item.fund_grant
    fund_item.should_receive(:belongs_to_touch_after_save_or_destroy_for_fund_grant)
    fund_item.save!
  end

  it "should save to the end of the list by default" do
    items = Array.new
    grant = create( :fund_grant )
    node = create( :node, :structure => grant.fund_source.structure,
      :item_quantity_limit => 3 )
    3.times do
      items << create( :fund_item, :fund_grant => grant, :node => node )
      grant.association(:fund_items).reset
    end
    3.times { |i| items[i].position.should eql( i + 1 ) }
  end

  it 'should save a nested item just before the sibling of its parent' do
    fund_item.save!
    fund_item.node.update_attribute :item_quantity_limit, 5
    child_node = create( :node, :parent => fund_item.node,
      :structure => fund_item.node.structure )
    sibling = create( :fund_item, :node => fund_item.node,
      :fund_grant => fund_item.fund_grant )
    sibling.position.should eql 2
    child = create( :fund_item, :node => child_node, :parent => fund_item,
      :fund_grant => fund_item.fund_grant )
    child.position.should eql 2
    sibling.reload
    sibling.position.should eql 3
  end

  context 'allowed_nodes' do

    let(:fund_request) { create(:fund_request,
      :fund_grant  => fund_item.fund_grant) }
    let(:unactionable_request) { create(:fund_request,
      :fund_grant => fund_item.fund_grant, :state => 'rejected',
      :reject_message => 'blah' ) }

    before(:each) do
      fund_item.save!
    end

    it 'should include root nodes of same structure that are under limit' do
      create(:fund_edition, :fund_request => fund_request,
        :fund_item => fund_item)
      fund_item.node.item_quantity_limit.should eql 1
      under_limit_node = create( :node, :structure => fund_item.node.structure )
      different_structure_node = create(:node)
      different_structure_node.structure.should_not eql fund_item.node.structure
      nonroot_node = create(:node, :parent => fund_item.node,
        :structure => fund_item.node.structure )
      unactionable_item = create(:fund_item, :node => under_limit_node,
        :fund_grant => fund_item.fund_grant )
      create(:fund_edition, :fund_request => unactionable_request,
        :fund_item => unactionable_item )
      item = build(:fund_item, :fund_grant => fund_item.fund_grant,
        :node => nil)
      item.allowed_nodes.length.should eql 1
      item.allowed_nodes.should include under_limit_node
    end

    it 'allowed_nodes should include correct child nodes that are under limit for a parent' do
      fund_item.save!
      create( :fund_edition, :fund_item => fund_item, :fund_request => unactionable_request )
      create( :fund_edition, :fund_item => fund_item, :fund_request => fund_request )
      fund_item.association(:fund_editions).reset
      at_limit_node = create(:node, :structure => fund_item.node.structure,
        :parent => fund_item.node )
      at_limit_item = create(:fund_item, :parent => fund_item, :node => at_limit_node,
        :fund_grant => fund_item.fund_grant)
      create(:fund_edition, :fund_item => at_limit_item,
        :fund_request => fund_request)
      under_limit_node = create(:node, :structure => fund_item.node.structure,
        :parent => fund_item.node )
      under_limit_item = create(:fund_item, :parent => fund_item,
        :node => under_limit_node, :fund_grant => fund_item.fund_grant )
      create(:fund_edition, :fund_item => under_limit_item,
        :fund_request => unactionable_request )
      other_root_node = create(:node, :structure => fund_item.node.structure )
      different_parent_node = create( :node,
        :structure => fund_item.node.structure, :parent => other_root_node )
      item = build(:fund_item, :parent => fund_item)
      item.allowed_nodes.length.should eql 1
      item.allowed_nodes.should include under_limit_node
    end
  end

  context 'child validations' do
    let( :child_node ) { create( :node, :structure => fund_item.node.structure,
        :parent => fund_item.node ) }

    it 'should save with a parent that is of a different fund_grant' do
      fund_item.save!
      create( :fund_item, :fund_grant => fund_item.fund_grant,
        :parent => fund_item, :node => child_node )
    end

    it 'should not save with a parent that is of a different fund_grant' do
      fund_item.save!
      other_parent = create( :fund_item, :fund_grant => create( :fund_grant,
        :fund_source => fund_item.fund_grant.fund_source ),
        :node => fund_item.node )
      fund_item.node.structure.association(:nodes).reset
      item = build( :fund_item, :fund_grant => fund_item.fund_grant,
        :parent => other_parent, :node => child_node )
      item.save.should be_false
      item.errors.first.should eql [ :parent, "must be part of the same fund grant" ]
    end
  end

  context 'appended and amended items' do
    let (:original_request) { create( :fund_request, fund_grant: fund_item.fund_grant,
      state: 'released' ) }
    let (:amended_request) { create( :fund_request, fund_grant: fund_item.fund_grant ) }
    before(:each) do
      fund_item.save!
      create( :fund_edition, fund_request: original_request, fund_item: fund_item )
      sleep 1
      create( :fund_edition, fund_request: amended_request, fund_item: fund_item )
    end

    it 'should have amended_in' do
      FundItem.amended_in(original_request).count.should eql 0
      FundItem.amended_in(original_request).length.should eql 0
      FundItem.amended_in(original_request).should be_empty
      FundItem.amended_in(amended_request).count.should eql 1
      FundItem.amended_in(amended_request).length.should eql 1
      FundItem.amended_in(amended_request).should include fund_item
      original_request.state = 'rejected'
      original_request.reject_message = 'not acceptable'
      original_request.save!
      FundItem.amended_in(amended_request).count.should eql 0
      FundItem.amended_in(amended_request).length.should eql 0
      FundItem.amended_in(amended_request).should be_empty
    end

    it 'should have appended_to' do
      FundItem.appended_to(original_request).count.should eql 1
      FundItem.appended_to(original_request).length.should eql 1
      FundItem.appended_to(original_request).should include fund_item
      FundItem.appended_to(amended_request).count.should eql 0
      FundItem.appended_to(amended_request).length.should eql 0
      FundItem.appended_to(amended_request).should be_empty
      original_request.state = 'rejected'
      original_request.reject_message = 'not acceptable'
      original_request.save!
      FundItem.appended_to(amended_request).count.should eql 1
      FundItem.appended_to(amended_request).length.should eql 1
      FundItem.appended_to(amended_request).should include fund_item
    end
  end

end

