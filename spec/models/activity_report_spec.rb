require 'spec_helper'

describe ActivityReport do
  before(:each) do
    @activity_report = Factory(:activity_report)
  end

  it 'should save with valid attributes' do
    @activity_report.id.should_not be_nil
  end

  it 'should not save without an organization' do
    @activity_report.organization = nil
    @activity_report.save.should be_false
  end

  it 'should not save without a description' do
    @activity_report.description =  nil
    @activity_report.save.should be_false
  end

  it 'should not save with an invalid starts_on' do
    @activity_report.starts_on = 'blah'
    @activity_report.save.should be_false
    @activity_report.starts_on = nil
    @activity_report.save.should be_false
  end

  it 'should not save with an invalid ends_on' do
    @activity_report.ends_on = @activity_report.starts_on - 1.day
    @activity_report.save.should be_false
    @activity_report.ends_on = nil
    @activity_report.save.should be_false
    @activity_report.ends_on = 'blah'
    @activity_report.save.should be_false
  end

  it 'should not save without a valid number_of_others' do
    @activity_report.number_of_others = nil
    @activity_report.save.should be_false
  end

  it 'should not save without valid number_of_* values' do
    %w( others undergrads grads ).each do |population|
      @activity_report = Factory(:activity_report)
      @activity_report.send("number_of_#{population}=", nil)
      @activity_report.save.should be_false
      @activity_report.send("number_of_#{population}=", 'blah')
      @activity_report.save.should be_false
      @activity_report.send("number_of_#{population}=", -1)
      @activity_report.save.should be_false
    end
  end

end

