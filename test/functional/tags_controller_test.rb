require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, :format => 'html'
    # no tags yet
    assert_response :missing
    t = Tag.new( :name => 'dumb tag')
    t.save!
    a = ArtPiece.new(:title => 'simple',
                     :tags => [ Tag.new(:name => 'one'), Tag.new(:name => 'two')])
    a.save!
    get :index, :format => 'html'
    assert_response :redirect
  end

  test "should get json list of tags" do
    get :index, :format => 'json'
    assert_response :success

    t = Tag.new( :name => 'dumb tag')
    t.save
    get :index, :format => 'json'
    assert_response :success
    assert_template nil
    
  end

  test "should not get new" do
    get :new
    assert_redirected_to error_path
  end

  test "should not create tag" do
    post :create, :tag => { }
    assert_redirected_to error_path
  end

  test "should show tag" do
    get :show, :id => tags(:one).to_param
    assert_response :success
    assert_template "show.html"
  end

  test "should not get edit" do
    get :edit, :id => tags(:one).to_param
    assert_redirected_to error_path
  end

  test "should not update tag" do
    put :update, :id => tags(:one).to_param, :tag => { }
    assert_redirected_to error_path
  end

  test "should destroy tag" do
    delete :destroy, :id => tags(:one).to_param
    assert_redirected_to error_path
  end

end
