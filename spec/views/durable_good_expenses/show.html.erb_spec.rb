require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/durable_good_expenses/show.html.erb" do
  include DurableGoodExpensesHelper
  before(:each) do
    assigns[:durable_good_expense] = @durable_good_expense = stub_model(DurableGoodExpense,
      :description => "value for description",
      :quantity => 1.5,
      :price => 1.5,
      :total => 9.99
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ description/)
    response.should have_text(/1\.5/)
    response.should have_text(/1\.5/)
    response.should have_text(/9\.99/)
  end
end

