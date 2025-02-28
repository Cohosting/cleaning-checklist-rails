require "test_helper"

class SectionGroupsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get section_groups_create_url
    assert_response :success
  end

  test "should get destroy" do
    get section_groups_destroy_url
    assert_response :success
  end

  test "should get move" do
    get section_groups_move_url
    assert_response :success
  end
end
