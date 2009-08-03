require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/attachments/edit.html.erb" do
  include AttachmentsHelper

  before(:each) do
    assigns[:attachment] = @attachment = stub_model(Attachment,
      :new_record? => false,
      :attachable_id => 1,
      :attachable_type => "value for attachable_type",
      :attachment_type => 1
    )
  end

  it "renders the edit attachment form" do
    render

    response.should have_tag("form[action=#{attachment_path(@attachment)}][method=post]") do
      with_tag('input#attachment_attachable_id[name=?]', "attachment[attachable_id]")
      with_tag('input#attachment_attachable_type[name=?]', "attachment[attachable_type]")
      with_tag('input#attachment_attachment_type[name=?]', "attachment[attachment_type]")
    end
  end
end
