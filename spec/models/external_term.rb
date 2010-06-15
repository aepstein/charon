require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RegistrationImporter::ExternalTerm do
  before(:each) do
    RegistrationImporter::ExternalTerm.delete_all
    @term = Factory(:external_term)
  end

  it "should create a new instance given valid attributes" do
    Factory(:external_term).term_id.should_not be_nil
  end

  it 'should return appropriate values for attributes' do
    time = Time.zone.now
    tests = [
      [:current, 'YES', be_true],
      [:current, 'NO', be_false],
      [:current, nil, be_false]
    ]
    getter_tests(@term, tests)
  end

  it 'should import a new record successfully' do
    import_result_test RegistrationImporter::ExternalTerm.import, [ 1, 0, 0 ]
    @term.current = 'NO'
    @term.current_changed?.should be_true
    @term.save
    import_result_test RegistrationImporter::ExternalTerm.import, [ 0, 1, 0 ]
    @term.destroy
    import_result_test RegistrationImporter::ExternalTerm.import, [ 0, 0, 1 ]
  end

  def getter_tests(object,tests)
    tests.each do |parameters|
      object.send(:write_attribute, parameters[0], parameters[1])
      object.send(parameters[0]).should parameters[2]
    end
  end

  def import_result_test(actual,expected)
    expected.each_index do |i|
      actual[ i ].should eql expected[ i ]
    end
  end

end

