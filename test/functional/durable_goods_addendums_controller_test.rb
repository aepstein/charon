require 'test_helper'

class DurableGoodsAddendumsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:durable_goods_addendums)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create durable_goods_addendum" do
    assert_difference('DurableGoodsAddendum.count') do
      post :create, :durable_goods_addendum => { }
    end

    assert_redirected_to durable_goods_addendum_path(assigns(:durable_goods_addendum))
  end

  test "should show durable_goods_addendum" do
    get :show, :id => durable_goods_addendums(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => durable_goods_addendums(:one).to_param
    assert_response :success
  end

  test "should update durable_goods_addendum" do
    put :update, :id => durable_goods_addendums(:one).to_param, :durable_goods_addendum => { }
    assert_redirected_to durable_goods_addendum_path(assigns(:durable_goods_addendum))
  end

  test "should destroy durable_goods_addendum" do
    assert_difference('DurableGoodsAddendum.count', -1) do
      delete :destroy, :id => durable_goods_addendums(:one).to_param
    end

    assert_redirected_to durable_goods_addendums_path
  end
end
