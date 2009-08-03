require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/attachment_types/new.html.erb" do
  include AttachmentTypesHelper

  before(:each) do
    assigns[:attachment_type] = stub_model(AttachmentType,
      :new_record? => true,
      :name => "value for name",
      :max_size_quantity => 1,
      :max_size_unit => "value for max_size_unit"
    )
  end

  it "renders new attachment_type form" do
    render

    response.should have_tag("form[action=?][method=post]", attachment_types_path) do
      with_tag("input#attachment_type_name[name=?]", "attachment_type[name]")
      with_tag("input#attachment_type_max_size_quantity[name=?]", "attachment_type[max_size_quantity]")
      with_tag("input#attachment_type_max_size_unit[name=?]", "attachment_type[max_size_unit]")
    end
  end
end
