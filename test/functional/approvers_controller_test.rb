require 'test_helper'

class ApproversControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:approvers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create approver" do
    assert_difference('Approver.count') do
      post :create, :approver => { }
    end

    assert_redirected_to approver_path(assigns(:approver))
  end

  test "should show approver" do
    get :show, :id => approvers(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => approvers(:one).to_param
    assert_response :success
  end

  test "should update approver" do
    put :update, :id => approvers(:one).to_param, :approver => { }
    assert_redirected_to approver_path(assigns(:approver))
  end

  test "should destroy approver" do
    assert_difference('Approver.count', -1) do
      delete :destroy, :id => approvers(:one).to_param
    end

    assert_redirected_to approvers_path
  end
end
