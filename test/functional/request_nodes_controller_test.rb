require 'test_helper'

class RequestNodesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:request_nodes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create request_node" do
    assert_difference('RequestNode.count') do
      post :create, :request_node => { }
    end

    assert_redirected_to request_node_path(assigns(:request_node))
  end

  test "should show request_node" do
    get :show, :id => request_nodes(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => request_nodes(:one).to_param
    assert_response :success
  end

  test "should update request_node" do
    put :update, :id => request_nodes(:one).to_param, :request_node => { }
    assert_redirected_to request_node_path(assigns(:request_node))
  end

  test "should destroy request_node" do
    assert_difference('RequestNode.count', -1) do
      delete :destroy, :id => request_nodes(:one).to_param
    end

    assert_redirected_to request_nodes_path
  end
end
