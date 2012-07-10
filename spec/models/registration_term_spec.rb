require 'spec_helper'

describe RegistrationTerm do

  let(:registration_term) { build :registration_term }

  context 'validations' do

    it "should save with valid properties" do
      registration_term.save!
    end

    it "should not save without an external_id" do
      registration_term.external_id = nil
      registration_term.save.should be_false
    end

    it "should not have changed_significantly if starts_at timestamp is unchanged" do
      registration_term.save!
      registration_term.starts_at = Time.zone.at(
        registration_term.starts_at.to_i.to_f + 0.001
      )
      registration_term.changed?.should be_true
      registration_term.changed_significantly?.should be_false
    end

    it "should have changed_significantly if starts_at timestamp is changed" do
      registration_term.save!
      registration_term.starts_at = Time.zone.at(
        registration_term.starts_at.to_i + 1
      )
      registration_term.changed_significantly?.should be_true
    end

  end

end

