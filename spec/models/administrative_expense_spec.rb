require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AdministrativeExpense do
  before(:each) do
    @expense = create(:administrative_expense)
  end

  it "should create a new instance given valid attributes" do
    @expense.id.should_not be_nil
  end

  it "should not save without a fund_edition" do
    @expense.fund_edition = nil
    @expense.save.should == false
  end

  it "should not save with invalid copies" do
    @expense.copies = nil
    @expense.save.should == false
    @expense.copies = -1
    @expense.save.should == false
  end

  it "should not save with invalid chalk" do
    @expense.chalk = nil
    @expense.save.should == false
    @expense.chalk = -1
    @expense.save.should == false
  end

  it "should not save with invalid sun_ads" do
    @expense.sun_ads = nil
    @expense.save.should == false
    @expense.sun_ads = -12.4
    @expense.save.should == false
  end

  it "should not save with invalid repairs_restocking" do
    @expense.repairs_restocking = nil
    @expense.save.should == false
    @expense.repairs_restocking = -12.4
    @expense.save.should == false
  end

  it "should not save with invalid mailbox_wsh" do
    @expense.mailbox_wsh = nil
    @expense.save.should == false
    @expense.mailbox_wsh = -12
    @expense.save.should == false
  end

end

