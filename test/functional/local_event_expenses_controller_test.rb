require 'test_helper'

class LocalEventExpensesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:local_event_expenses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create local_event_expense" do
    assert_difference('LocalEventExpense.count') do
      post :create, :local_event_expense => { }
    end

    assert_redirected_to local_event_expense_path(assigns(:local_event_expense))
  end

  test "should show local_event_expense" do
    get :show, :id => local_event_expenses(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => local_event_expenses(:one).to_param
    assert_response :success
  end

  test "should update local_event_expense" do
    put :update, :id => local_event_expenses(:one).to_param, :local_event_expense => { }
    assert_redirected_to local_event_expense_path(assigns(:local_event_expense))
  end

  test "should destroy local_event_expense" do
    assert_difference('LocalEventExpense.count', -1) do
      delete :destroy, :id => local_event_expenses(:one).to_param
    end

    assert_redirected_to local_event_expenses_path
  end
end
