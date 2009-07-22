require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/frameworks/index.html.erb" do
  include FrameworksHelper

  before(:each) do
    assigns[:frameworks] = [
      stub_model(Framework,
        :name => "value for name",
        :member_percentage => 1,
        :member_percentage_type => "value for member_percentage_type"
      ),
      stub_model(Framework,
        :name => "value for name",
        :member_percentage => 1,
        :member_percentage_type => "value for member_percentage_type"
      )
    ]
  end

  it "renders a list of frameworks" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for member_percentage_type".to_s, 2)
  end
end
