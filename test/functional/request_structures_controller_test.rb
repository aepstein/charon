require 'test_helper'

class RequestStructuresControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:request_structures)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create request_structure" do
    assert_difference('RequestStructure.count') do
      post :create, :request_structure => { }
    end

    assert_redirected_to request_structure_path(assigns(:request_structure))
  end

  test "should show request_structure" do
    get :show, :id => request_structures(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => request_structures(:one).to_param
    assert_response :success
  end

  test "should update request_structure" do
    put :update, :id => request_structures(:one).to_param, :request_structure => { }
    assert_redirected_to request_structure_path(assigns(:request_structure))
  end

  test "should destroy request_structure" do
    assert_difference('RequestStructure.count', -1) do
      delete :destroy, :id => request_structures(:one).to_param
    end

    assert_redirected_to request_structures_path
  end
end
