require "test_helper"

class UpsellsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @upsell = upsells(:one)
  end

  test "should get index" do
    get upsells_url
    assert_response :success
  end

  test "should get new" do
    get new_upsell_url
    assert_response :success
  end

  test "should create upsell" do
    assert_difference("Upsell.count") do
      post upsells_url, params: { upsell: { description: @upsell.description, price: @upsell.price, title: @upsell.title } }
    end

    assert_redirected_to upsell_url(Upsell.last)
  end

  test "should show upsell" do
    get upsell_url(@upsell)
    assert_response :success
  end

  test "should get edit" do
    get edit_upsell_url(@upsell)
    assert_response :success
  end

  test "should update upsell" do
    patch upsell_url(@upsell), params: { upsell: { description: @upsell.description, price: @upsell.price, title: @upsell.title } }
    assert_redirected_to upsell_url(@upsell)
  end

  test "should destroy upsell" do
    assert_difference("Upsell.count", -1) do
      delete upsell_url(@upsell)
    end

    assert_redirected_to upsells_url
  end
end
