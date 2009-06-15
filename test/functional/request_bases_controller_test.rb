require 'test_helper'

class RequestBasesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:request_bases)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create request_basis" do
    assert_difference('RequestBasis.count') do
      post :create, :request_basis => { }
    end

    assert_redirected_to request_basis_path(assigns(:request_basis))
  end

  test "should show request_basis" do
    get :show, :id => request_bases(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => request_bases(:one).to_param
    assert_response :success
  end

  test "should update request_basis" do
    put :update, :id => request_bases(:one).to_param, :request_basis => { }
    assert_redirected_to request_basis_path(assigns(:request_basis))
  end

  test "should destroy request_basis" do
    assert_difference('RequestBasis.count', -1) do
      delete :destroy, :id => request_bases(:one).to_param
    end

    assert_redirected_to request_bases_path
  end
end
