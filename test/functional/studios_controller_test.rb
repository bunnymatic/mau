require 'test_helper'

class StudiosControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:studios)
    assert_template 'index.html'
  end

  test "should get new" do
    get :new
    assert_response :redirect
    assert_redirected_to error_path
  end

  test "should not create studio" do
    assert_difference('Studio.count',0) do
      post :create, :studio => { }
    end
    assert_redirected_to error_path
  end

  test "should show studio" do
    get :show, :id => studios(:s1890).to_param
    assert_response :success
    assert_template "show.html"
  end

  test "should not get edit" do
    get :edit, :id => studios(:as).to_param
    assert_redirected_to error_path
  end

  test "should no update studio" do
    put :update, :id => studios(:blue).to_param, :studio => { }
    assert_redirected_to error_path
  end

  test "should not destroy studio" do
    assert_difference('Studio.count', 0) do
      delete :destroy, :id => studios(:blue).to_param
    end

    assert_redirected_to error_path
  end
end
