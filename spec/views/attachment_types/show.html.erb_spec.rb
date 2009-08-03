require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/attachment_types/show.html.erb" do
  include AttachmentTypesHelper
  before(:each) do
    assigns[:attachment_type] = @attachment_type = stub_model(AttachmentType,
      :name => "value for name",
      :max_size_quantity => 1,
      :max_size_unit => "value for max_size_unit"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ name/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ max_size_unit/)
  end
end
