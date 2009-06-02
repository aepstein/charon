require 'test_helper'

class PublicationExpensesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:publication_expenses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create publication_expense" do
    assert_difference('PublicationExpense.count') do
      post :create, :publication_expense => { }
    end

    assert_redirected_to publication_expense_path(assigns(:publication_expense))
  end

  test "should show publication_expense" do
    get :show, :id => publication_expenses(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => publication_expenses(:one).to_param
    assert_response :success
  end

  test "should update publication_expense" do
    put :update, :id => publication_expenses(:one).to_param, :publication_expense => { }
    assert_redirected_to publication_expense_path(assigns(:publication_expense))
  end

  test "should destroy publication_expense" do
    assert_difference('PublicationExpense.count', -1) do
      delete :destroy, :id => publication_expenses(:one).to_param
    end

    assert_redirected_to publication_expenses_path
  end
end
