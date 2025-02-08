require "test_helper"

class JobTasksControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    get job_tasks_update_url
    assert_response :success
  end
end
