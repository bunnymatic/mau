require 'test_helper'
require 'unit/artist_test'

class ArtPiecesControllerTest < ActionController::TestCase

  def setup
    m1 = Medium.new :name => 'medium1', :id => 1
    m1.save!
    a = ArtistTest.send(:create_artist)
    @artist_id = a.id
    @medium_id = m1.id
  end
  
  def teardown
  end

  test "should not get index" do
    get :index
    assert_redirected_to error_path
  end

  test "should not get new if logged out" do
    get :new
    assert_redirected_to new_session_path
  end

  test "should not create art_piece if logged out" do
    assert_difference('ArtPiece.count',0) do
      post :create, :art_piece => { :artist_id => @artist_id }
    end
    assert_redirected_to new_session_path
  end

  test "should not show art_piece if artpiece doesn't have an artist" do
    get :show, :id => art_pieces(:hot).to_param
    assert_response :missing
  end

  test "should not edit if logged out" do
    get :edit, :id => art_pieces(:not).to_param
    assert_response :redirect
    assert_redirected_to new_session_path
  end

  test "should not update art_piece if logged out" do
    put :update, :id => art_pieces(:hot).to_param, :art_piece => { }
    assert_redirected_to new_session_path
  end

  test "should not destroy art_piece if logged out" do
    assert_difference('ArtPiece.count', 0) do
      delete :destroy, :id => art_pieces(:not).to_param
    end

    assert_redirected_to new_session_path
  end
end
