require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/frameworks/show.html.erb" do
  include FrameworksHelper
  before(:each) do
    assigns[:framework] = @framework = stub_model(Framework,
      :name => "value for name",
      :member_percentage => 1,
      :member_percentage_type => "value for member_percentage_type"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ name/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ member_percentage_type/)
  end
end
