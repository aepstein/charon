require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/frameworks/edit.html.erb" do
  include FrameworksHelper

  before(:each) do
    assigns[:framework] = @framework = stub_model(Framework,
      :new_record? => false,
      :name => "value for name",
      :member_percentage => 1,
      :member_percentage_type => "value for member_percentage_type"
    )
  end

  it "renders the edit framework form" do
    render

    response.should have_tag("form[action=#{framework_path(@framework)}][method=post]") do
      with_tag('input#framework_name[name=?]', "framework[name]")
      with_tag('input#framework_member_percentage[name=?]', "framework[member_percentage]")
      with_tag('input#framework_member_percentage_type[name=?]', "framework[member_percentage_type]")
    end
  end
end
