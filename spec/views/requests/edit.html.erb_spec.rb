require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/requests/edit.html.erb" do
  include RequestsHelper
  
  before(:each) do
    assigns[:request] = @request = stub_model(Request,
      :new_record? => false,
      :request_structure_id => 1
    )
  end

  it "renders the edit request form" do
    render
    
    response.should have_tag("form[action=#{request_path(@request)}][method=post]") do
      with_tag('input#request_request_structure_id[name=?]', "request[request_structure_id]")
    end
  end
end


