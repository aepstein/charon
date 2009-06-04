require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AdministrativeExpensesController do

  def mock_administrative_expense(stubs={})
    @mock_administrative_expense ||= mock_model(AdministrativeExpense, stubs)
  end
  
  describe "GET index" do
    it "assigns all administrative_expenses as @administrative_expenses" do
      AdministrativeExpense.stub!(:find).with(:all).and_return([mock_administrative_expense])
      get :index
      assigns[:administrative_expenses].should == [mock_administrative_expense]
    end
  end

  describe "GET show" do
    it "assigns the requested administrative_expense as @administrative_expense" do
      AdministrativeExpense.stub!(:find).with("37").and_return(mock_administrative_expense)
      get :show, :id => "37"
      assigns[:administrative_expense].should equal(mock_administrative_expense)
    end
  end

  describe "GET new" do
    it "assigns a new administrative_expense as @administrative_expense" do
      AdministrativeExpense.stub!(:new).and_return(mock_administrative_expense)
      get :new
      assigns[:administrative_expense].should equal(mock_administrative_expense)
    end
  end

  describe "GET edit" do
    it "assigns the requested administrative_expense as @administrative_expense" do
      AdministrativeExpense.stub!(:find).with("37").and_return(mock_administrative_expense)
      get :edit, :id => "37"
      assigns[:administrative_expense].should equal(mock_administrative_expense)
    end
  end

  describe "POST create" do
    
    describe "with valid params" do
      it "assigns a newly created administrative_expense as @administrative_expense" do
        AdministrativeExpense.stub!(:new).with({'these' => 'params'}).and_return(mock_administrative_expense(:save => true))
        post :create, :administrative_expense => {:these => 'params'}
        assigns[:administrative_expense].should equal(mock_administrative_expense)
      end

      it "redirects to the created administrative_expense" do
        AdministrativeExpense.stub!(:new).and_return(mock_administrative_expense(:save => true))
        post :create, :administrative_expense => {}
        response.should redirect_to(administrative_expense_url(mock_administrative_expense))
      end
    end
    
    describe "with invalid params" do
      it "assigns a newly created but unsaved administrative_expense as @administrative_expense" do
        AdministrativeExpense.stub!(:new).with({'these' => 'params'}).and_return(mock_administrative_expense(:save => false))
        post :create, :administrative_expense => {:these => 'params'}
        assigns[:administrative_expense].should equal(mock_administrative_expense)
      end

      it "re-renders the 'new' template" do
        AdministrativeExpense.stub!(:new).and_return(mock_administrative_expense(:save => false))
        post :create, :administrative_expense => {}
        response.should render_template('new')
      end
    end
    
  end

  describe "PUT update" do
    
    describe "with valid params" do
      it "updates the requested administrative_expense" do
        AdministrativeExpense.should_receive(:find).with("37").and_return(mock_administrative_expense)
        mock_administrative_expense.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :administrative_expense => {:these => 'params'}
      end

      it "assigns the requested administrative_expense as @administrative_expense" do
        AdministrativeExpense.stub!(:find).and_return(mock_administrative_expense(:update_attributes => true))
        put :update, :id => "1"
        assigns[:administrative_expense].should equal(mock_administrative_expense)
      end

      it "redirects to the administrative_expense" do
        AdministrativeExpense.stub!(:find).and_return(mock_administrative_expense(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(administrative_expense_url(mock_administrative_expense))
      end
    end
    
    describe "with invalid params" do
      it "updates the requested administrative_expense" do
        AdministrativeExpense.should_receive(:find).with("37").and_return(mock_administrative_expense)
        mock_administrative_expense.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :administrative_expense => {:these => 'params'}
      end

      it "assigns the administrative_expense as @administrative_expense" do
        AdministrativeExpense.stub!(:find).and_return(mock_administrative_expense(:update_attributes => false))
        put :update, :id => "1"
        assigns[:administrative_expense].should equal(mock_administrative_expense)
      end

      it "re-renders the 'edit' template" do
        AdministrativeExpense.stub!(:find).and_return(mock_administrative_expense(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end
    
  end

  describe "DELETE destroy" do
    it "destroys the requested administrative_expense" do
      AdministrativeExpense.should_receive(:find).with("37").and_return(mock_administrative_expense)
      mock_administrative_expense.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the administrative_expenses list" do
      AdministrativeExpense.stub!(:find).and_return(mock_administrative_expense(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(administrative_expenses_url)
    end
  end

end
