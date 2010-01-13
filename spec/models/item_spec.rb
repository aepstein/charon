require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Item do
  before(:each) do
    basis = Factory(:basis)
    basis.structure.nodes.create(Factory.attributes_for(:node).merge( :category => Factory(:category) ) )
    request = Factory(:request, :basis => basis)
    @item = request.items.build(:node => basis.structure.nodes.first)
  end

  it "should save with valid attributes" do
    Factory(:item).id.should_not be_nil
  end

  it "should not save if there are already too many corresponding root items" do
    first = Factory(:item)
    second = Factory.build(:item, :request => first.request, :node => first.node)
    second.save.should == false
  end

  it "should not save if there are already too many corresponding items under parent" do
    parent = Factory(:item)
    child_node = Factory(:node, :parent => parent.node, :structure => parent.node.structure )
    first = Factory(:item, :request => parent.request, :parent => parent, :node => child_node)
    second = Factory.build(:item, :request => parent.request, :parent => parent, :node => child_node)
    second.save.should == false
  end

  it "should have a editions.perspectives method that returns perspectives of editions represented" do
    item = Factory(:item)
    item.editions.next.perspective.should == 'requestor'
    item = Factory(:administrative_expense).edition.item
    item.editions.perspectives.size.should == 1
    item.editions.perspectives.first.should == 'requestor'
    item.editions.next.perspective.should == 'reviewer'
  end

  it "should have may_create? which returns same value as request.may_update?" do
    @item.request.stub!(:may_update?).and_return(true)
    @item.may_create?(nil).should == true
    @item.request.stub!(:may_update?).and_return(false)
    @item.may_create?(nil).should == false
  end

  it "should have may_update? which returns same value as request.may_update?" do
    @item.request.stub!(:may_update?).and_return(true)
    @item.may_update?(nil).should == true
    @item.request.stub!(:may_update?).and_return(false)
    @item.may_update?(nil).should == false
  end

  it "should have may_destroy? which returns same value as request.may_update?" do
    @item.request.stub!(:may_update?).and_return(true)
    @item.may_destroy?(nil).should == true
    @item.request.stub!(:may_update?).and_return(false)
    @item.may_destroy?(nil).should == false
  end

  it "should have may_see? which returns same value as request.may_see?" do
    @item.request.stub!(:may_see?).and_return(true)
    @item.may_see?(nil).should == true
    @item.request.stub!(:may_see?).and_return(false)
    @item.may_see?(nil).should == false
  end

  it "should set its title from the node" do
    item = Factory(:item)
    item.title.should == item.node.name
  end

  it "should call request.touch on save" do
    @item.request
    @item.should_receive(:belongs_to_touch_after_save_or_destroy_for_request)
    @item.save
  end

  it "should save to the end of the list by default and act as list" do
    first = @item
    first.save
    request = @item.request
    node = @item.node
    node.item_quantity_limit = 3
    node.save
    second = @item.request.items.create(:node => node)
    second.id.should_not be_nil
    third = @item.request.items.create(:node => node)
    third.id.should_not be_nil
    first.position.should == 1
    second.position.should == 2
    third.position.should == 3
    third.insert_at(second.position)
    first.reload
    second.reload
    first.position.should == 1
    second.position.should == 3
    third.position.should == 2
  end

  it "should have an initialize_next_edition that initialize the next edition in each child and in self" do
    first = @item
    first.save
    request = @item.request
    node = @item.node
    node.item_quantity_limit = 2
    node.save
    child_node = node.structure.nodes.create( Factory.attributes_for(:node).merge(
      :parent_id => node.id, :category => Factory(:category) ) )
    child_node.id.should_not be_nil
    second = @item.request.items.create(:node => node)
    child = @item.request.items.create(:node => child_node, :parent => first)
    first.id.should_not be_nil
    second.id.should_not be_nil
    child.id.should_not be_nil
    first.initialize_next_edition
    first.editions.first.class.should == Edition
    first.children.first.editions.first.class.should == Edition
  end
end

