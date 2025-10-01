require "application_system_test_case"

class SuppliersTest < ApplicationSystemTestCase
  setup do
    @supplier = suppliers(:one)
  end

  test "visiting the index" do
    visit suppliers_url
    assert_selector "h1", text: "Suppliers"
  end

  test "should create supplier" do
    visit suppliers_url
    click_on "New supplier"

    check "Active" if @supplier.active
    fill_in "Category", with: @supplier.category
    fill_in "Group by color", with: @supplier.group_by_color
    check "Inactive" if @supplier.inactive
    fill_in "Link", with: @supplier.link
    fill_in "Name", with: @supplier.name
    fill_in "No", with: @supplier.no
    fill_in "Sku", with: @supplier.sku
    click_on "Create Supplier"

    assert_text "Supplier was successfully created"
    click_on "Back"
  end

  test "should update Supplier" do
    visit supplier_url(@supplier)
    click_on "Edit this supplier", match: :first

    check "Active" if @supplier.active
    fill_in "Category", with: @supplier.category
    fill_in "Group by color", with: @supplier.group_by_color
    check "Inactive" if @supplier.inactive
    fill_in "Link", with: @supplier.link
    fill_in "Name", with: @supplier.name
    fill_in "No", with: @supplier.no
    fill_in "Sku", with: @supplier.sku
    click_on "Update Supplier"

    assert_text "Supplier was successfully updated"
    click_on "Back"
  end

  test "should destroy Supplier" do
    visit supplier_url(@supplier)
    click_on "Destroy this supplier", match: :first

    assert_text "Supplier was successfully destroyed"
  end
end
