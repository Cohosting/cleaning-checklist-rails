require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get organizations_show_url
    assert_response :success
  end
end
