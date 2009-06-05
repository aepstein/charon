require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/durable_good_expenses/index.html.erb" do
  include DurableGoodExpensesHelper
  
  before(:each) do
    assigns[:durable_good_expenses] = [
      stub_model(DurableGoodExpense,
        :description => "value for description",
        :quantity => 1.5,
        :price => 1.5,
        :total => 9.99
      ),
      stub_model(DurableGoodExpense,
        :description => "value for description",
        :quantity => 1.5,
        :price => 1.5,
        :total => 9.99
      )
    ]
  end

  it "renders a list of durable_good_expenses" do
    render
    response.should have_tag("tr>td", "value for description".to_s, 2)
    response.should have_tag("tr>td", 1.5.to_s, 2)
    response.should have_tag("tr>td", 1.5.to_s, 2)
    response.should have_tag("tr>td", 9.99.to_s, 2)
  end
end

