require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AdministrativeExpensesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "administrative_expenses", :action => "index").should == "/administrative_expenses"
    end
  
    it "maps #new" do
      route_for(:controller => "administrative_expenses", :action => "new").should == "/administrative_expenses/new"
    end
  
    it "maps #show" do
      route_for(:controller => "administrative_expenses", :action => "show", :id => "1").should == "/administrative_expenses/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "administrative_expenses", :action => "edit", :id => "1").should == "/administrative_expenses/1/edit"
    end

  it "maps #create" do
    route_for(:controller => "administrative_expenses", :action => "create").should == {:path => "/administrative_expenses", :method => :post}
  end

  it "maps #update" do
    route_for(:controller => "administrative_expenses", :action => "update", :id => "1").should == {:path =>"/administrative_expenses/1", :method => :put}
  end
  
    it "maps #destroy" do
      route_for(:controller => "administrative_expenses", :action => "destroy", :id => "1").should == {:path =>"/administrative_expenses/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/administrative_expenses").should == {:controller => "administrative_expenses", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/administrative_expenses/new").should == {:controller => "administrative_expenses", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/administrative_expenses").should == {:controller => "administrative_expenses", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/administrative_expenses/1").should == {:controller => "administrative_expenses", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/administrative_expenses/1/edit").should == {:controller => "administrative_expenses", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/administrative_expenses/1").should == {:controller => "administrative_expenses", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/administrative_expenses/1").should == {:controller => "administrative_expenses", :action => "destroy", :id => "1"}
    end
  end
end
