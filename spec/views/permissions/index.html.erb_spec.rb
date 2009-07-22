require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/permissions/index.html.erb" do
  include PermissionsHelper

  before(:each) do
    assigns[:permissions] = [
      stub_model(Permission,
        :framework => ,
        :state => "value for state",
        :role => ,
        :action => "value for action",
        :stage_id => 1
      ),
      stub_model(Permission,
        :framework => ,
        :state => "value for state",
        :role => ,
        :action => "value for action",
        :stage_id => 1
      )
    ]
  end

  it "renders a list of permissions" do
    render
    response.should have_tag("tr>td", .to_s, 2)
    response.should have_tag("tr>td", "value for state".to_s, 2)
    response.should have_tag("tr>td", .to_s, 2)
    response.should have_tag("tr>td", "value for action".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end
