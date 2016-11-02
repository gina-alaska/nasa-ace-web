require 'test_helper'

class ViewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @view = views(:one)
  end

  test "should get index" do
    get views_url
    assert_response :success
  end

  test "should get new" do
    get new_view_url
    assert_response :success
  end

  test "should create view" do
    assert_difference('View.count') do
      post views_url, params: { view: { name: @view.name + " testing" } }
    end

    assert_redirected_to view_url(View.last)
  end

  test "should show view" do
    get view_url(@view)
    assert_response :success
  end

  test "should get edit" do
    get edit_view_url(@view)
    assert_response :success
  end

  test "should update view" do
    patch view_url(@view), params: { view: { name: @view.name } }
    assert_redirected_to view_url(@view)
  end

  test "should destroy view" do
    assert_difference('View.count', -1) do
      delete view_url(@view)
    end

    assert_redirected_to views_url
  end
end
