require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/durable_good_expenses/edit.html.erb" do
  include DurableGoodExpensesHelper
  
  before(:each) do
    assigns[:durable_good_expense] = @durable_good_expense = stub_model(DurableGoodExpense,
      :new_record? => false,
      :description => "value for description",
      :quantity => 1.5,
      :price => 1.5,
      :total => 9.99
    )
  end

  it "renders the edit durable_good_expense form" do
    render
    
    response.should have_tag("form[action=#{durable_good_expense_path(@durable_good_expense)}][method=post]") do
      with_tag('input#durable_good_expense_description[name=?]', "durable_good_expense[description]")
      with_tag('input#durable_good_expense_quantity[name=?]', "durable_good_expense[quantity]")
      with_tag('input#durable_good_expense_price[name=?]', "durable_good_expense[price]")
      with_tag('input#durable_good_expense_total[name=?]', "durable_good_expense[total]")
    end
  end
end


