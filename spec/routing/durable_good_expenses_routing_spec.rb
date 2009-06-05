require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DurableGoodExpensesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "durable_good_expenses", :action => "index").should == "/durable_good_expenses"
    end
  
    it "maps #new" do
      route_for(:controller => "durable_good_expenses", :action => "new").should == "/durable_good_expenses/new"
    end
  
    it "maps #show" do
      route_for(:controller => "durable_good_expenses", :action => "show", :id => "1").should == "/durable_good_expenses/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "durable_good_expenses", :action => "edit", :id => "1").should == "/durable_good_expenses/1/edit"
    end

  it "maps #create" do
    route_for(:controller => "durable_good_expenses", :action => "create").should == {:path => "/durable_good_expenses", :method => :post}
  end

  it "maps #update" do
    route_for(:controller => "durable_good_expenses", :action => "update", :id => "1").should == {:path =>"/durable_good_expenses/1", :method => :put}
  end
  
    it "maps #destroy" do
      route_for(:controller => "durable_good_expenses", :action => "destroy", :id => "1").should == {:path =>"/durable_good_expenses/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/durable_good_expenses").should == {:controller => "durable_good_expenses", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/durable_good_expenses/new").should == {:controller => "durable_good_expenses", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/durable_good_expenses").should == {:controller => "durable_good_expenses", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/durable_good_expenses/1").should == {:controller => "durable_good_expenses", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/durable_good_expenses/1/edit").should == {:controller => "durable_good_expenses", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/durable_good_expenses/1").should == {:controller => "durable_good_expenses", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/durable_good_expenses/1").should == {:controller => "durable_good_expenses", :action => "destroy", :id => "1"}
    end
  end
end
