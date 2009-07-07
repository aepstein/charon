require 'test_helper'

class FulfillmentsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fulfillments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fulfillment" do
    assert_difference('Fulfillment.count') do
      post :create, :fulfillment => { }
    end

    assert_redirected_to fulfillment_path(assigns(:fulfillment))
  end

  test "should show fulfillment" do
    get :show, :id => fulfillments(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => fulfillments(:one).to_param
    assert_response :success
  end

  test "should update fulfillment" do
    put :update, :id => fulfillments(:one).to_param, :fulfillment => { }
    assert_redirected_to fulfillment_path(assigns(:fulfillment))
  end

  test "should destroy fulfillment" do
    assert_difference('Fulfillment.count', -1) do
      delete :destroy, :id => fulfillments(:one).to_param
    end

    assert_redirected_to fulfillments_path
  end
end
