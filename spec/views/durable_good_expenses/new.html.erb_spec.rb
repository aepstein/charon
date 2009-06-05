require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/durable_good_expenses/new.html.erb" do
  include DurableGoodExpensesHelper
  
  before(:each) do
    assigns[:durable_good_expense] = stub_model(DurableGoodExpense,
      :new_record? => true,
      :description => "value for description",
      :quantity => 1.5,
      :price => 1.5,
      :total => 9.99
    )
  end

  it "renders new durable_good_expense form" do
    render
    
    response.should have_tag("form[action=?][method=post]", durable_good_expenses_path) do
      with_tag("input#durable_good_expense_description[name=?]", "durable_good_expense[description]")
      with_tag("input#durable_good_expense_quantity[name=?]", "durable_good_expense[quantity]")
      with_tag("input#durable_good_expense_price[name=?]", "durable_good_expense[price]")
      with_tag("input#durable_good_expense_total[name=?]", "durable_good_expense[total]")
    end
  end
end


