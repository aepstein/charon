require 'test_helper'

class TravelEventExpensesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:travel_event_expenses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create travel_event_expense" do
    assert_difference('TravelEventExpense.count') do
      post :create, :travel_event_expense => { }
    end

    assert_redirected_to travel_event_expense_path(assigns(:travel_event_expense))
  end

  test "should show travel_event_expense" do
    get :show, :id => travel_event_expenses(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => travel_event_expenses(:one).to_param
    assert_response :success
  end

  test "should update travel_event_expense" do
    put :update, :id => travel_event_expenses(:one).to_param, :travel_event_expense => { }
    assert_redirected_to travel_event_expense_path(assigns(:travel_event_expense))
  end

  test "should destroy travel_event_expense" do
    assert_difference('TravelEventExpense.count', -1) do
      delete :destroy, :id => travel_event_expenses(:one).to_param
    end

    assert_redirected_to travel_event_expenses_path
  end
end
