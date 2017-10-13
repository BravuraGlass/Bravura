require 'test_helper'

class StatusChecklistItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @status_checklist_item = status_checklist_items(:one)
  end

  test "should get index" do
    get status_checklist_items_url
    assert_response :success
  end

  test "should get new" do
    get new_status_checklist_item_url
    assert_response :success
  end

  test "should create status_checklist_item" do
    assert_difference('StatusChecklistItem.count') do
      post status_checklist_items_url, params: { status_checklist_item: { description: @status_checklist_item.description, status_id: @status_checklist_item.status_id, title: @status_checklist_item.title } }
    end

    assert_redirected_to status_checklist_item_url(StatusChecklistItem.last)
  end

  test "should show status_checklist_item" do
    get status_checklist_item_url(@status_checklist_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_status_checklist_item_url(@status_checklist_item)
    assert_response :success
  end

  test "should update status_checklist_item" do
    patch status_checklist_item_url(@status_checklist_item), params: { status_checklist_item: { description: @status_checklist_item.description, status_id: @status_checklist_item.status_id, title: @status_checklist_item.title } }
    assert_redirected_to status_checklist_item_url(@status_checklist_item)
  end

  test "should destroy status_checklist_item" do
    assert_difference('StatusChecklistItem.count', -1) do
      delete status_checklist_item_url(@status_checklist_item)
    end

    assert_redirected_to status_checklist_items_url
  end
end
