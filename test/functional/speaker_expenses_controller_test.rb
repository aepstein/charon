require 'test_helper'

class SpeakerExpensesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:speaker_expenses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create speaker_expense" do
    assert_difference('SpeakerExpense.count') do
      post :create, :speaker_expense => { }
    end

    assert_redirected_to speaker_expense_path(assigns(:speaker_expense))
  end

  test "should show speaker_expense" do
    get :show, :id => speaker_expenses(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => speaker_expenses(:one).to_param
    assert_response :success
  end

  test "should update speaker_expense" do
    put :update, :id => speaker_expenses(:one).to_param, :speaker_expense => { }
    assert_redirected_to speaker_expense_path(assigns(:speaker_expense))
  end

  test "should destroy speaker_expense" do
    assert_difference('SpeakerExpense.count', -1) do
      delete :destroy, :id => speaker_expenses(:one).to_param
    end

    assert_redirected_to speaker_expenses_path
  end
end
