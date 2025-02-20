require "application_system_test_case"

class UpsellsTest < ApplicationSystemTestCase
  setup do
    @upsell = upsells(:one)
  end

  test "visiting the index" do
    visit upsells_url
    assert_selector "h1", text: "Upsells"
  end

  test "should create upsell" do
    visit upsells_url
    click_on "New upsell"

    fill_in "Description", with: @upsell.description
    fill_in "Price", with: @upsell.price
    fill_in "Title", with: @upsell.title
    click_on "Create Upsell"

    assert_text "Upsell was successfully created"
    click_on "Back"
  end

  test "should update Upsell" do
    visit upsell_url(@upsell)
    click_on "Edit this upsell", match: :first

    fill_in "Description", with: @upsell.description
    fill_in "Price", with: @upsell.price
    fill_in "Title", with: @upsell.title
    click_on "Update Upsell"

    assert_text "Upsell was successfully updated"
    click_on "Back"
  end

  test "should destroy Upsell" do
    visit upsell_url(@upsell)
    click_on "Destroy this upsell", match: :first

    assert_text "Upsell was successfully destroyed"
  end
end
