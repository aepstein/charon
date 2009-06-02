require 'test_helper'

class AdministrativeExpensesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:administrative_expenses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create administrative_expense" do
    assert_difference('AdministrativeExpense.count') do
      post :create, :administrative_expense => { }
    end

    assert_redirected_to administrative_expense_path(assigns(:administrative_expense))
  end

  test "should show administrative_expense" do
    get :show, :id => administrative_expenses(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => administrative_expenses(:one).to_param
    assert_response :success
  end

  test "should update administrative_expense" do
    put :update, :id => administrative_expenses(:one).to_param, :administrative_expense => { }
    assert_redirected_to administrative_expense_path(assigns(:administrative_expense))
  end

  test "should destroy administrative_expense" do
    assert_difference('AdministrativeExpense.count', -1) do
      delete :destroy, :id => administrative_expenses(:one).to_param
    end

    assert_redirected_to administrative_expenses_path
  end
end
