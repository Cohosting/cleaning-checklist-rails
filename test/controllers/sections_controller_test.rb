require "test_helper"

class SectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get sections_create_url
    assert_response :success
  end

  test "should get update" do
    get sections_update_url
    assert_response :success
  end

  test "should get destroy" do
    get sections_destroy_url
    assert_response :success
  end

  test "should get move" do
    get sections_move_url
    assert_response :success
  end
end
