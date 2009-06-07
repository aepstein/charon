require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/requests/index.html.erb" do
  include RequestsHelper
  
  before(:each) do
    assigns[:requests] = [
      stub_model(Request,
        :request_structure_id => 1
      ),
      stub_model(Request,
        :request_structure_id => 1
      )
    ]
  end

  it "renders a list of requests" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end

