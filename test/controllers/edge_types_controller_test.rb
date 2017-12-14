require 'test_helper'

class EdgeTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @edge_type = edge_types(:one)
  end

  test "should get index" do
    get edge_types_url
    assert_response :success
  end

  test "should get new" do
    get new_edge_type_url
    assert_response :success
  end

  test "should create edge_type" do
    assert_difference('EdgeType.count') do
      post edge_types_url, params: { edge_type: { name: @edge_type.name } }
    end

    assert_redirected_to edge_type_url(EdgeType.last)
  end

  test "should show edge_type" do
    get edge_type_url(@edge_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_edge_type_url(@edge_type)
    assert_response :success
  end

  test "should update edge_type" do
    patch edge_type_url(@edge_type), params: { edge_type: { name: @edge_type.name } }
    assert_redirected_to edge_type_url(@edge_type)
  end

  test "should destroy edge_type" do
    assert_difference('EdgeType.count', -1) do
      delete edge_type_url(@edge_type)
    end

    assert_redirected_to edge_types_url
  end
end
