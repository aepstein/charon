require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DurableGoodExpensesController do

  def mock_durable_good_expense(stubs={})
    @mock_durable_good_expense ||= mock_model(DurableGoodExpense, stubs)
  end
  
  describe "GET index" do
    it "assigns all durable_good_expenses as @durable_good_expenses" do
      DurableGoodExpense.stub!(:find).with(:all).and_return([mock_durable_good_expense])
      get :index
      assigns[:durable_good_expenses].should == [mock_durable_good_expense]
    end
  end

  describe "GET show" do
    it "assigns the requested durable_good_expense as @durable_good_expense" do
      DurableGoodExpense.stub!(:find).with("37").and_return(mock_durable_good_expense)
      get :show, :id => "37"
      assigns[:durable_good_expense].should equal(mock_durable_good_expense)
    end
  end

  describe "GET new" do
    it "assigns a new durable_good_expense as @durable_good_expense" do
      DurableGoodExpense.stub!(:new).and_return(mock_durable_good_expense)
      get :new
      assigns[:durable_good_expense].should equal(mock_durable_good_expense)
    end
  end

  describe "GET edit" do
    it "assigns the requested durable_good_expense as @durable_good_expense" do
      DurableGoodExpense.stub!(:find).with("37").and_return(mock_durable_good_expense)
      get :edit, :id => "37"
      assigns[:durable_good_expense].should equal(mock_durable_good_expense)
    end
  end

  describe "POST create" do
    
    describe "with valid params" do
      it "assigns a newly created durable_good_expense as @durable_good_expense" do
        DurableGoodExpense.stub!(:new).with({'these' => 'params'}).and_return(mock_durable_good_expense(:save => true))
        post :create, :durable_good_expense => {:these => 'params'}
        assigns[:durable_good_expense].should equal(mock_durable_good_expense)
      end

      it "redirects to the created durable_good_expense" do
        DurableGoodExpense.stub!(:new).and_return(mock_durable_good_expense(:save => true))
        post :create, :durable_good_expense => {}
        response.should redirect_to(durable_good_expense_url(mock_durable_good_expense))
      end
    end
    
    describe "with invalid params" do
      it "assigns a newly created but unsaved durable_good_expense as @durable_good_expense" do
        DurableGoodExpense.stub!(:new).with({'these' => 'params'}).and_return(mock_durable_good_expense(:save => false))
        post :create, :durable_good_expense => {:these => 'params'}
        assigns[:durable_good_expense].should equal(mock_durable_good_expense)
      end

      it "re-renders the 'new' template" do
        DurableGoodExpense.stub!(:new).and_return(mock_durable_good_expense(:save => false))
        post :create, :durable_good_expense => {}
        response.should render_template('new')
      end
    end
    
  end

  describe "PUT update" do
    
    describe "with valid params" do
      it "updates the requested durable_good_expense" do
        DurableGoodExpense.should_receive(:find).with("37").and_return(mock_durable_good_expense)
        mock_durable_good_expense.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :durable_good_expense => {:these => 'params'}
      end

      it "assigns the requested durable_good_expense as @durable_good_expense" do
        DurableGoodExpense.stub!(:find).and_return(mock_durable_good_expense(:update_attributes => true))
        put :update, :id => "1"
        assigns[:durable_good_expense].should equal(mock_durable_good_expense)
      end

      it "redirects to the durable_good_expense" do
        DurableGoodExpense.stub!(:find).and_return(mock_durable_good_expense(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(durable_good_expense_url(mock_durable_good_expense))
      end
    end
    
    describe "with invalid params" do
      it "updates the requested durable_good_expense" do
        DurableGoodExpense.should_receive(:find).with("37").and_return(mock_durable_good_expense)
        mock_durable_good_expense.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :durable_good_expense => {:these => 'params'}
      end

      it "assigns the durable_good_expense as @durable_good_expense" do
        DurableGoodExpense.stub!(:find).and_return(mock_durable_good_expense(:update_attributes => false))
        put :update, :id => "1"
        assigns[:durable_good_expense].should equal(mock_durable_good_expense)
      end

      it "re-renders the 'edit' template" do
        DurableGoodExpense.stub!(:find).and_return(mock_durable_good_expense(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end
    
  end

  describe "DELETE destroy" do
    it "destroys the requested durable_good_expense" do
      DurableGoodExpense.should_receive(:find).with("37").and_return(mock_durable_good_expense)
      mock_durable_good_expense.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the durable_good_expenses list" do
      DurableGoodExpense.stub!(:find).and_return(mock_durable_good_expense(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(durable_good_expenses_url)
    end
  end

end
