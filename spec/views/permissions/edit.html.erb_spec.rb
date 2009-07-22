require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/permissions/edit.html.erb" do
  include PermissionsHelper

  before(:each) do
    assigns[:permission] = @permission = stub_model(Permission,
      :new_record? => false,
      :framework => ,
      :state => "value for state",
      :role => ,
      :action => "value for action",
      :stage_id => 1
    )
  end

  it "renders the edit permission form" do
    render

    response.should have_tag("form[action=#{permission_path(@permission)}][method=post]") do
      with_tag('input#permission_framework[name=?]', "permission[framework]")
      with_tag('input#permission_state[name=?]', "permission[state]")
      with_tag('input#permission_role[name=?]', "permission[role]")
      with_tag('input#permission_action[name=?]', "permission[action]")
      with_tag('input#permission_stage_id[name=?]', "permission[stage_id]")
    end
  end
end
