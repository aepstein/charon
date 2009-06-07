require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/requests/show.html.erb" do
  include RequestsHelper
  before(:each) do
    assigns[:request] = @request = stub_model(Request,
      :request_structure_id => 1
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
  end
end

