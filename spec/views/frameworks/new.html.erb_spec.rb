require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/frameworks/new.html.erb" do
  include FrameworksHelper

  before(:each) do
    assigns[:framework] = stub_model(Framework,
      :new_record? => true,
      :name => "value for name",
      :member_percentage => 1,
      :member_percentage_type => "value for member_percentage_type"
    )
  end

  it "renders new framework form" do
    render

    response.should have_tag("form[action=?][method=post]", frameworks_path) do
      with_tag("input#framework_name[name=?]", "framework[name]")
      with_tag("input#framework_member_percentage[name=?]", "framework[member_percentage]")
      with_tag("input#framework_member_percentage_type[name=?]", "framework[member_percentage_type]")
    end
  end
end
