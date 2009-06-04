require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/administrative_expenses/edit.html.erb" do
  include AdministrativeExpensesHelper
  
  before(:each) do
    assigns[:administrative_expense] = @administrative_expense = stub_model(AdministrativeExpense,
      :new_record? => false,
      :copies => 1,
      :copies_expense => 9.99,
      :repairs_restocking => 9.99,
      :mailbox_wsh => 1,
      :total_request => 9.99,
      :total => 9.99
    )
  end

  it "renders the edit administrative_expense form" do
    render
    
    response.should have_tag("form[action=#{administrative_expense_path(@administrative_expense)}][method=post]") do
      with_tag('input#administrative_expense_copies[name=?]', "administrative_expense[copies]")
      with_tag('input#administrative_expense_copies_expense[name=?]', "administrative_expense[copies_expense]")
      with_tag('input#administrative_expense_repairs_restocking[name=?]', "administrative_expense[repairs_restocking]")
      with_tag('input#administrative_expense_mailbox_wsh[name=?]', "administrative_expense[mailbox_wsh]")
      with_tag('input#administrative_expense_total_request[name=?]', "administrative_expense[total_request]")
      with_tag('input#administrative_expense_total[name=?]', "administrative_expense[total]")
    end
  end
end


