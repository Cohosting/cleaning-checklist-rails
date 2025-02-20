require "test_helper"

class JobSharesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get job_shares_show_url
    assert_response :success
  end
end
