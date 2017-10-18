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
    get workspace_view_url(@workspace, @view)
    assert_response :success
  end

  test "should get edit" do
    get edit_workspace_view_url(@workspace, @view)
    assert_response :success
  end

  test "should update view" do
    patch workspace_view_url(@workspace, @view), params: { view: { name: @view.name } }
    assert_redirected_to workspace_view_url(@workspace, @view)
  end

  test "should destroy view" do
    assert_difference('@workspace.views.count', -1) do
      delete workspace_view_url(@workspace, @view)
    end

    assert_redirected_to workspaces_url
  end

  test "should duplicate view" do
    assert_difference('@workspace.views.count') do
      get duplicate_workspace_view_url(@workspace, @view)
    end

    assert_response :redirect
  end

  test "should fail to duplicate view" do
    @view.duplicate
    get duplicate_workspace_view_url(@workspace, @view)

    assert_response :success
    assert_equal flash['error'], 'Error saving duplicate view'
  end
end
