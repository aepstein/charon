require 'spec_helper'

shared_examples 'notifiable' do
  let( :notifiable ) { create( described_class.to_s.underscore ) }

  it 'should have a no_event_notice scope' do
    events.each do |event|
      scope = described_class.send( "no_#{event}_notice" )
      scope.should include notifiable
      notifiable.update_column "#{event}_notice_at", Time.zone.now
      scope.reset.should_not include notifiable
    end
  end

  it 'should have a no_event_notice_since scope' do
    events.each do |event|
      t = Time.zone.now
      scope = described_class.send( "no_#{event}_notice_since", t )
      scope.should include notifiable
      notifiable.update_column "#{event}_notice_at", (t - 1.minute)
      scope.reset.should include notifiable
      notifiable.update_column "#{event}_notice_at", (t + 1.minute)
      scope.reset.should_not include notifiable
    end
  end

  it 'should have a send_event_notice! method' do
    events.each do |event|
      notifiable.send("#{event}_notice_at").should be_nil
      notifiable.send("send_#{event}_notice!").should be_true
      notifiable.send("#{event}_notice_at").should_not be_nil
    end
  end
end

shared_examples 'notifiable_with_condition' do
  let( :notifiable ) { create( described_class.to_s.underscore ) }

  it 'should have a send_event_notice! method that does not fulfill' do
    events.each do |event|
      notifiable.send("#{event}_notice_at").should be_nil
      notifiable.send("send_#{event}_notice!").should be_false
      notifiable.send("#{event}_notice_at").should be_nil
    end
  end
end

describe FundRequest do
  it_behaves_like 'notifiable' do
    before(:each) do
      notifiable.fund_queue = notifiable.fund_grant.fund_source.fund_queues.first
      notifiable.save!
      notifiable.stub(:require_requestor_recipients!).and_return(true)
    end

    let( :notifiable ) { create( :fund_request, :withdrawn_at => Time.zone.now ) }
    let( :events ) { [ :started, :tentative, :finalized, :submitted,
      :released, :allocated, :rejected, :withdrawn ] }
  end

  it_behaves_like 'notifiable_with_condition' do
    let( :events ) { [ :started, :tentative, :finalized, :rejected, :submitted,
      :released, :withdrawn ] }
  end
end

describe Organization do
  it_behaves_like 'notifiable' do
    let( :events ) { [ :registration_required ] }
  end
end

