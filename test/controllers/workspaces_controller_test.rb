# frozen_string_literal: true
require 'test_helper'

class WorkspacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workspace = workspaces(:one)
  end

  test "should get index" do
    get workspaces_url
    assert_response :success
  end

  test "should get new" do
    get new_workspace_url
    assert_response :success
  end

  test "should redirect show to first view" do
    get workspace_url(@workspace)

    assert_redirected_to workspace_view_path(@workspace, @workspace.views.first)
  end

  test "should redirect to root if no views" do
    @workspace = Workspace.create(name: 'Failing workspace')
    get workspace_url(@workspace)

    assert_redirected_to root_url
  end

  test "should create workspace" do
    assert_difference('Workspace.count') do
      post workspaces_url, params: { workspace: { name: @workspace.name + " testing" } }
    end

    assert_redirected_to workspace_url(Workspace.last)
  end

  test "should get edit" do
    get edit_workspace_url(@workspace)
    assert_response :success
  end

  test "should update workspace" do
    patch workspace_url(@workspace), params: { workspace: { name: @workspace.name } }
    assert_redirected_to workspace_url(@workspace)
  end

  test "should destroy workspace" do
    assert_difference('Workspace.count', -1) do
      delete workspace_url(@workspace)
    end

    assert_redirected_to workspaces_url
  end
end
