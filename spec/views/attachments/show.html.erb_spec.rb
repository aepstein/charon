require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/attachments/show.html.erb" do
  include AttachmentsHelper
  before(:each) do
    assigns[:attachment] = @attachment = stub_model(Attachment,
      :attachable_id => 1,
      :attachable_type => "value for attachable_type",
      :attachment_type => 1
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
    response.should have_text(/value\ for\ attachable_type/)
    response.should have_text(/1/)
  end
end
