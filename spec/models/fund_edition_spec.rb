require 'spec_helper'

describe FundEdition do
  let( :fund_edition ) { build(:fund_edition) }

  it 'should save with valid attributes' do
    fund_edition.save!
  end

  context 'validations' do

    it 'should not save without an fund_item' do
      fund_edition.fund_item = nil
      fund_edition.save.should be_false
    end

    it 'should not save with an invalid perspective' do
      fund_edition.perspective = 'invalid'
      FundEdition::PERSPECTIVES.should_not include(fund_edition.perspective)
      fund_edition.save.should be_false
    end

    it 'should not save with a duplicate perspective for fund_item' do
      fund_edition.save!
      duplicate_fund_edition = build( :fund_edition,
       :fund_item => fund_edition.fund_item )
      duplicate_fund_edition.perspective.should eql fund_edition.perspective
      duplicate_fund_edition.save.should be_false
    end

    it 'should not save without an invalid amount' do
      fund_edition.amount = nil
      fund_edition.save.should be_false
      fund_edition.amount = -1.02
      fund_edition.save.should be_false
    end

    it 'should not save with an amount higher than fund_item.node.item_amount_limit' do
      fund_edition.amount = fund_edition.fund_item.node.item_amount_limit + 1.0
      fund_edition.save.should be_false
      fund_edition.errors.first.should eql [ :amount,
        " is greater than maximum for #{fund_edition.fund_item.node}."]
      fund_edition.max_fund_request.should eql fund_edition.fund_item.node.item_amount_limit
    end

    it 'should not save with an amount higher than requestable.max_fund_request' do
      detail = create(:administrative_expense)
      detail.id.should_not be_nil
      fund_edition = detail.fund_edition
      fund_edition.requestable(true).should_not be_nil
      fund_edition.requestable.stub!(:max_fund_request).and_return(50.0)
      fund_edition.amount = 500.0
      fund_edition.save.should eql false
      fund_edition.max_fund_request.should eql fund_edition.requestable.max_fund_request
    end

    it 'should not save with an amount higher than original fund_edition amount' do
      fund_edition.save!
      original = fund_edition
      original.reload
      review = original.fund_item.fund_editions.
        build_next_for_fund_request( original.fund_request )
      review.amount = ( original.amount + 1.0 )
      review.perspective.should eql 'reviewer'
      review.amount.should > original.amount
      review.previous.should eql original
      review.save.should be_false
      review.errors.first.should eql [:amount, " is greater than original fund_request amount."]
      review.max_fund_request.should eql original.amount
    end

    it 'should not save a non-initial fund_edition if a previous fund_edition does not exist' do
      fund_edition.perspective = FundEdition::PERSPECTIVES.last
      fund_edition.save.should be_false
    end

  end

  context 'item repositioning' do
    let( :node ) { create( :node, :item_quantity_limit => 5 ) }
    let( :source ) { create( :fund_source, :structure => node.structure ) }
    let( :grant ) { create( :fund_grant, :fund_source => source ) }
    let( :displaceable ) { create( :fund_item, :node => node, :fund_grant => grant ) }
    let( :displacor ) { create(:fund_item, :node => node, :fund_grant => grant ) }

    it 'should reposition associated item to displace_item that is a sibling in same request' do
      request = create( :fund_edition, :fund_item => displaceable ).fund_request
      edition = create( :fund_edition, :fund_item => displacor, :fund_request => request )
      request.association(:fund_items).reset
      edition.displace_item = displaceable
      edition.save!
    end

    it 'should not save if displace_item is not a sibling' do
      child_node = create(:node, :parent => node, :structure => node.structure)
      request = create( :fund_edition, :fund_item => displaceable ).fund_request
      edition = create( :fund_edition, :fund_item => displacor, :fund_request => request )
      child_item = create( :fund_item, :node => child_node, :parent => displaceable,
        :fund_grant => grant )
      child_edition = create( :fund_edition, :fund_item => child_item, :fund_request => request )
      request.association(:fund_items).reset
      edition.valid?.should be_true
      edition.displace_item = child_item
      edition.save.should be_false
    end

    it 'should not save if displace_item is not in request' do
      request = create( :fund_edition, :fund_item => displaceable ).fund_request
      request.update_attribute :state, 'submitted'
      other_request = create( :fund_request, :fund_grant => request.fund_grant )
      edition = create( :fund_edition, :fund_item => displacor,
        :fund_request => other_request )
      edition.valid?.should be_true
      edition.displace_item = displaceable
      edition.save.should be_false
    end
  end

  context 'siblings' do
    it 'should return apppropriate values for previous_perspective and next_perspective' do
      fund_edition.save!
      fund_edition.perspective = FundEdition::PERSPECTIVES.first
      fund_edition.previous_perspective.should be_nil
      fund_edition.next_perspective.should eql FundEdition::PERSPECTIVES.last
      fund_edition.perspective = FundEdition::PERSPECTIVES.last
      fund_edition.previous_perspective.should eql FundEdition::PERSPECTIVES.first
      fund_edition.next_perspective.should be_nil
    end

    it 'next should return nil if next edition is new' do
      fund_edition.save!
      fund_edition.reload
      fund_edition.next.should be_nil
      next_edition = fund_edition.fund_item.fund_editions.build_next_for_fund_request( fund_edition.fund_request )
      fund_edition.fund_item.object_id.should eql next_edition.fund_item.object_id
      fund_edition.fund_item.fund_editions.for_request( fund_edition.fund_request ).should include fund_edition
      fund_edition.fund_item.fund_editions.length.should eql 2
      fund_edition.next.should eql next_edition
      next_edition.previous.should eql fund_edition
    end

    it 'next and previous should return appropriate results' do
      fund_edition.save!
      fund_edition.reload
      next_edition = create( :fund_edition,
        :perspective => FundEdition::PERSPECTIVES.last,
        :fund_request => fund_edition.fund_request,
        :fund_item => fund_edition.fund_item )
      fund_edition.next.should eql next_edition
      next_edition.next.should be_nil
      fund_edition.previous.should be_nil
      next_edition.previous.should eql fund_edition
    end
  end

  it 'should have a title method that returns the requestable title if defined, nil otherwise' do
    title = 'a title'
    fund_edition = create(:administrative_expense).fund_edition
    fund_edition.requestable(true).should_not be_nil
    fund_edition.title.should be_nil
    fund_edition.administrative_expense.stub!(:title).and_return(nil)
    fund_edition.title.should be_nil
    fund_edition.administrative_expense.stub!(:title).and_return(title)
    fund_edition.title.should eql title
  end

  it 'should set its fund_item\'s title to its own title if it has one on save' do
    title = 'a title'
    fund_edition.save!
    fund_edition.stub!(:title).and_return(title)
    fund_edition.title.should_not eql fund_edition.fund_item.title
    fund_edition.save
    FundItem.find(fund_edition.fund_item.id).title.should eql title
  end
end

