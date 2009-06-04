require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/administrative_expenses/index.html.erb" do
  include AdministrativeExpensesHelper
  
  before(:each) do
    assigns[:administrative_expenses] = [
      stub_model(AdministrativeExpense,
        :copies => 1,
        :copies_expense => 9.99,
        :repairs_restocking => 9.99,
        :mailbox_wsh => 1,
        :total_request => 9.99,
        :total => 9.99
      ),
      stub_model(AdministrativeExpense,
        :copies => 1,
        :copies_expense => 9.99,
        :repairs_restocking => 9.99,
        :mailbox_wsh => 1,
        :total_request => 9.99,
        :total => 9.99
      )
    ]
  end

  it "renders a list of administrative_expenses" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 9.99.to_s, 2)
    response.should have_tag("tr>td", 9.99.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 9.99.to_s, 2)
    response.should have_tag("tr>td", 9.99.to_s, 2)
  end
end

