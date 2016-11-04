# frozen_string_literal: true
require 'test_helper'

class ViewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workspace = workspaces(:one)
    @view = views(:one)
  end

  test "should get index" do
    get workspace_views_url(@workspace)
    assert_response :success
  end

  test "should get new" do
    get new_workspace_view_url(@workspace)
    assert_response :success
  end

  test "should create view" do
    assert_difference('@workspace.views.count') do
      post workspace_views_url(@workspace), params: { view: { name: @view.name + " testing" } }
    end

    assert_redirected_to workspace_view_url(@workspace, View.last)
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
    assert_response :success
    #assert_redirected_to view_url(@view)
  end

  test "should destroy view" do
    assert_difference('View.count', -1) do
      delete view_url(@view)
    end

    assert_redirected_to views_url
  end
end
