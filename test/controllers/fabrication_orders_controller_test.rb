require 'test_helper'

class FabricationOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fabrication_order = fabrication_orders(:one)
  end

  test "should get index" do
    get fabrication_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_fabrication_order_url
    assert_response :success
  end

  test "should create fabrication_order" do
    assert_difference('FabricationOrder.count') do
      post fabrication_orders_url, params: { fabrication_order: { description: @fabrication_order.description, job_id: @fabrication_order.job_id, status: @fabrication_order.status, title: @fabrication_order.title } }
    end

    assert_redirected_to fabrication_order_url(FabricationOrder.last)
  end

  test "should show fabrication_order" do
    get fabrication_order_url(@fabrication_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_fabrication_order_url(@fabrication_order)
    assert_response :success
  end

  test "should update fabrication_order" do
    patch fabrication_order_url(@fabrication_order), params: { fabrication_order: { description: @fabrication_order.description, job_id: @fabrication_order.job_id, status: @fabrication_order.status, title: @fabrication_order.title } }
    assert_redirected_to fabrication_order_url(@fabrication_order)
  end

  test "should destroy fabrication_order" do
    assert_difference('FabricationOrder.count', -1) do
      delete fabrication_order_url(@fabrication_order)
    end

    assert_redirected_to fabrication_orders_url
  end
end
