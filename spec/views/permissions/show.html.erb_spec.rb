require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/permissions/show.html.erb" do
  include PermissionsHelper
  before(:each) do
    assigns[:permission] = @permission = stub_model(Permission,
      :framework => ,
      :state => "value for state",
      :role => ,
      :action => "value for action",
      :stage_id => 1
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(//)
    response.should have_text(/value\ for\ state/)
    response.should have_text(//)
    response.should have_text(/value\ for\ action/)
    response.should have_text(/1/)
  end
end
