require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/administrative_expenses/show.html.erb" do
  include AdministrativeExpensesHelper
  before(:each) do
    assigns[:administrative_expense] = @administrative_expense = stub_model(AdministrativeExpense,
      :copies => 1,
      :copies_expense => 9.99,
      :repairs_restocking => 9.99,
      :mailbox_wsh => 1,
      :total_request => 9.99,
      :total => 9.99
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
    response.should have_text(/9\.99/)
    response.should have_text(/9\.99/)
    response.should have_text(/1/)
    response.should have_text(/9\.99/)
    response.should have_text(/9\.99/)
  end
end

