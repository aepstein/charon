shared_examples 'fulfillable scopes and requirements' do
  let(:framework) { create :framework }
  let(:fulfillable_requirement) { framework.requirements << build( :requirement, framework: nil, fulfillable: fulfillable ); framework.requirements.last }
  let(:unfulfillable_requirement) { framework.requirements << build( :requirement, framework: nil, fulfillable: unfulfillable ); framework.requirements.last }

  before(:each) { membership; fulfillable_requirement; unfulfillable_requirement }

  it "should appear in fulfilled_by/unfulfilled_by fulfiller" do
    described_class.fulfilled_by( fulfiller ).should include fulfillable
    described_class.fulfilled_by( fulfiller ).should_not include unfulfillable
  end

  it "should appear in global requirement fulfilled_by/unfulfilled_by fulfiller" do
    requirement_specs
  end

  it "should appear in matching role requirement fulfilled_by/unfulfilled_by fulfiller" do
    requirements.each { |r| r.update_column :role_id, membership.role_id }
    requirement_specs
  end

  it "should fulfill requirements restricted to other roles" do
    role = create(:requestor_role); role.id.should_not eql membership.role_id
    requirements.each { |r| r.update_column :role_id, role.id }
    Requirement.fulfilled_by( membership ).should include fulfillable_requirement
    Requirement.fulfilled_by( membership ).should include unfulfillable_requirement
    Requirement.unfulfilled_by( membership ).should_not include fulfillable_requirement
    Requirement.unfulfilled_by( membership ).should_not include unfulfillable_requirement
  end

  it "should fulfill the membership once unfulfillable global requirement is removed" do
    fulfillment_specs
  end

  it "should fulfill the membership once unfulfillable matching role requirement is removed" do
    requirements.each { |r| r.update_column :role_id, membership.role_id }
    fulfillment_specs
  end

  def requirements; [ fulfillable_requirement, unfulfillable_requirement ]; end
  def fulfiller; membership.send described_class.fulfiller_type.underscore.to_sym; end
  def requirement_specs
    Requirement.fulfilled_by( membership ).should include fulfillable_requirement
    Requirement.fulfilled_by( membership ).should_not include unfulfillable_requirement
    Requirement.unfulfilled_by( membership ).should_not include fulfillable_requirement
    Requirement.unfulfilled_by( membership ).should include unfulfillable_requirement
  end
  def fulfillment_specs
    framework.reload; framework.update_memberships
    membership.association(:frameworks).reset
    membership.frameworks.should_not include unfulfillable_requirement.framework
    unfulfillable_requirement.destroy
    unfulfillable_requirement.framework.save!
    membership.association(:frameworks).reset
    membership.frameworks.should include unfulfillable_requirement.framework
  end
end

shared_examples 'fulfillable module' do
  let(:fulfiller_type) { fulfiller_class.to_s }

  it "should have correct fulfillable_type" do
    described_class.fulfiller_type.should eql fulfiller_type
  end

  it "should have correct fulfillable_class" do
    described_class.fulfiller_class.to_s.should eql fulfiller_class.to_s
  end

  it "should call update_frameworks on update" do
    fulfillable = create(described_class.to_s.underscore.to_sym)
    fulfillable.should_receive :update_frameworks
    touch( fulfillable )
    fulfillable.save!
  end
end

