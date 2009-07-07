require 'test_helper'

class RegisteredMembershipConditionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:registered_membership_conditions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create registered_membership_condition" do
    assert_difference('RegisteredMembershipCondition.count') do
      post :create, :registered_membership_condition => { }
    end

    assert_redirected_to registered_membership_condition_path(assigns(:registered_membership_condition))
  end

  test "should show registered_membership_condition" do
    get :show, :id => registered_membership_conditions(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => registered_membership_conditions(:one).to_param
    assert_response :success
  end

  test "should update registered_membership_condition" do
    put :update, :id => registered_membership_conditions(:one).to_param, :registered_membership_condition => { }
    assert_redirected_to registered_membership_condition_path(assigns(:registered_membership_condition))
  end

  test "should destroy registered_membership_condition" do
    assert_difference('RegisteredMembershipCondition.count', -1) do
      delete :destroy, :id => registered_membership_conditions(:one).to_param
    end

    assert_redirected_to registered_membership_conditions_path
  end
end
