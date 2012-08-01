require 'spec_helper'

shared_examples 'notifiable' do
  let( :notifiable ) { create( described_class.to_s.underscore ) }

  it 'should have a no_event_notice scope' do
    scope = described_class.send( "no_#{event}_notice" )
    scope.should include notifiable
    notifiable.update_column "#{event}_notice_at", Time.zone.now
    scope.reset.should_not include notifiable
  end

  it 'should have a no_event_notice_since scope' do
    t = Time.zone.now
    scope = described_class.send( "no_#{event}_notice_since", t )
    scope.should include notifiable
    notifiable.update_column "#{event}_notice_at", (t - 1.minute)
    scope.reset.should include notifiable
    notifiable.update_column "#{event}_notice_at", (t + 1.minute)
    scope.reset.should_not include notifiable
  end

  it 'should have a send_event_notice! method' do
    notifiable.send("#{event}_notice_at").should be_nil
    notifiable.send("send_#{event}_notice!").should be_true
    notifiable.send("#{event}_notice_at").should_not be_nil
  end
end

shared_examples 'notifiable_with_condition' do
  let( :notifiable ) { create( described_class.to_s.underscore ) }

  it 'should have a send_event_notice! method that does not fulfill' do
    notifiable.send("require_requestor_recipients!").should be_false
    notifiable.send("#{event}_notice_at").should be_nil
    notifiable.send("send_#{event}_notice!").should be_false
    notifiable.send("#{event}_notice_at").should be_nil
  end
end

