require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/attachments/index.html.erb" do
  include AttachmentsHelper

  before(:each) do
    assigns[:attachments] = [
      stub_model(Attachment,
        :attachable_id => 1,
        :attachable_type => "value for attachable_type",
        :attachment_type => 1
      ),
      stub_model(Attachment,
        :attachable_id => 1,
        :attachable_type => "value for attachable_type",
        :attachment_type => 1
      )
    ]
  end

  it "renders a list of attachments" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for attachable_type".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end
