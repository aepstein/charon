require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/attachment_types/index.html.erb" do
  include AttachmentTypesHelper

  before(:each) do
    assigns[:attachment_types] = [
      stub_model(AttachmentType,
        :name => "value for name",
        :max_size_quantity => 1,
        :max_size_unit => "value for max_size_unit"
      ),
      stub_model(AttachmentType,
        :name => "value for name",
        :max_size_quantity => 1,
        :max_size_unit => "value for max_size_unit"
      )
    ]
  end

  it "renders a list of attachment_types" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for max_size_unit".to_s, 2)
  end
end
