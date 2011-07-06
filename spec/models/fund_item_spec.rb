require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FundItem do
  before(:each) do
    fund_source = Factory(:fund_source)
    node = fund_source.structure.nodes.build
    Factory.attributes_for(:node).merge( :category => Factory(:category)
      ).each do |k,v|
      node.send "#{k}=", v
    end
    node.save!
    fund_request = Factory(:fund_request, :fund_source => fund_source)
    @fund_item = fund_request.fund_items.build
    @fund_item.node = node
  end

  it "should save with valid attributes" do
    Factory(:fund_item).id.should_not be_nil
  end

  it "should not save if there are already too many corresponding root fund_items" do
    first = Factory(:fund_item)
    second = Factory.build(:fund_item, :fund_request => first.fund_request, :node => first.node)
    second.save.should be_false
  end

  it "should not save if there are already too many corresponding fund_items under parent" do
    parent = Factory(:fund_item)
    child_node = Factory(:node, :parent => parent.node, :structure => parent.node.structure )
    first = Factory(:fund_item, :fund_request => parent.fund_request, :parent => parent, :node => child_node)
    second = Factory.build(:fund_item, :fund_request => parent.fund_request, :parent => parent, :node => child_node)
    second.save.should be_false
  end

  it "should have a fund_editions.perspectives method that returns perspectives of fund_editions represented" do
    fund_item = Factory(:fund_item)
    fund_item.fund_editions.next.perspective.should eql 'fund_requestor'
    fund_item = Factory(:fund_edition).fund_item
    fund_item.reload
    fund_item.fund_editions.perspectives.size.should eql 1
    fund_item.fund_editions.perspectives.first.should eql 'fund_requestor'
    fund_item.fund_editions.next.perspective.should eql 'reviewer'
  end

  it "should set its title from the node" do
    fund_item = Factory(:fund_item)
    fund_item.title.should eql fund_item.node.name
  end

  it "should call fund_request.touch on save" do
    @fund_item.fund_request
    @fund_item.should_receive(:belongs_to_touch_after_save_or_destroy_for_fund_request)
    @fund_item.save!
  end

  it "should save to the end of the list by default and act as list" do
    first = @fund_item
    first.save!
    fund_request = @fund_item.fund_request
    node = @fund_item.node
    node.fund_item_quantity_limit = 3
    node.save
    second = @fund_item.fund_request.fund_items.build
    second.node = node
    second.save!
    @fund_item.reload
    third = @fund_item.fund_request.fund_items.build
    third.node = node
    third.save!
    first.position.should eql 1
    second.position.should eql 2
    third.position.should eql 3
    third.insert_at(second.position)
    first.reload
    second.reload
    first.position.should eql 1
    second.position.should eql 3
    third.position.should eql 2
  end

  it "should have an initialize_next_fund_edition that initialize the next fund_edition in each child and in self" do
    first = @fund_item
    first.save!
    fund_request = @fund_item.fund_request
    node = @fund_item.node
    node.fund_item_quantity_limit = 2
    node.save
    child_node = node.structure.nodes.build
    Factory.attributes_for(:node).merge( :parent_id => node.id,
      :category => Factory(:category) ).each do |k,v|
      child_node.send "#{k}=", v
    end
    child_node.save!
    second = @fund_item.fund_request.fund_items.build
    second.node = node
    second.save!
    child = @fund_item.fund_request.fund_items.build
    child.node = child_node
    child.parent = first
    child.save!
    first.initialize_next_fund_edition
    first.fund_editions.first.class.should eql FundEdition
    first.children.first.fund_editions.first.class.should eql FundEdition
  end
end

