require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/requests/new.html.erb" do
  include RequestsHelper
  
  before(:each) do
    assigns[:request] = stub_model(Request,
      :new_record? => true,
      :request_structure_id => 1
    )
  end

  it "renders new request form" do
    render
    
    response.should have_tag("form[action=?][method=post]", requests_path) do
      with_tag("input#request_request_structure_id[name=?]", "request[request_structure_id]")
    end
  end
end


