require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/attachment_types/edit.html.erb" do
  include AttachmentTypesHelper

  before(:each) do
    assigns[:attachment_type] = @attachment_type = stub_model(AttachmentType,
      :new_record? => false,
      :name => "value for name",
      :max_size_quantity => 1,
      :max_size_unit => "value for max_size_unit"
    )
  end

  it "renders the edit attachment_type form" do
    render

    response.should have_tag("form[action=#{attachment_type_path(@attachment_type)}][method=post]") do
      with_tag('input#attachment_type_name[name=?]', "attachment_type[name]")
      with_tag('input#attachment_type_max_size_quantity[name=?]', "attachment_type[max_size_quantity]")
      with_tag('input#attachment_type_max_size_unit[name=?]', "attachment_type[max_size_unit]")
    end
  end
end
