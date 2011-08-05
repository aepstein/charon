require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FundItem do
  let( :fund_item ) { build(:fund_item) }

  it "should save with valid attributes" do
    fund_item.save!
  end

  it "should not save if there are already too many corresponding root fund_items" do
    first = create(:fund_item)
    second = build(:fund_item, :fund_grant => first.fund_grant, :node => first.node)
    second.save.should be_false
  end

  it "should not save if there are already too many corresponding fund_items under parent" do
    parent = create(:fund_item)
    child_node = create(:node, :parent => parent.node, :structure => parent.node.structure )
    first = create(:fund_item, :fund_grant => parent.fund_grant, :parent => parent, :node => child_node)
    second = build(:fund_item, :fund_grant => parent.fund_grant, :parent => parent, :node => child_node)
    second.save.should be_false
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

  it "should save to the end of the list by default and act as list" do
    items = Array.new
    grant = create( :fund_grant )
    node = create( :node, :structure => grant.fund_source.structure,
      :item_quantity_limit => 3 )
    3.times do
      items << create( :fund_item, :fund_grant => grant, :node => node )
      grant.association(:fund_items).reset
    end
    3.times { |i| items[i].position.should eql( i + 1 ) }
    items[2].insert_at 2
    items.each { |item| item.reload }
    items[1].position.should eql 3
    items[2].position.should eql 2
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

  context 'fund_editions association' do
    pending 'for_request'
    pending 'previous_to'
    pending 'next_to'
  end

end

