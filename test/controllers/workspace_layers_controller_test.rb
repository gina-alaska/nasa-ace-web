# frozen_string_literal: true
require 'test_helper'

class WorkspaceLayersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workspace_layer = workspace_layers(:one)
  end

  test "should get index" do
    get workspace_layers_url
    assert_response :success
  end

  test "should get new" do
    get new_workspace_layer_url
    assert_response :success
  end

  test "should create workspace_layer" do
    assert_difference('WorkspaceLayer.count') do
      post workspace_layers_url, params: {
        workspace_layer: {
          layer_id: layers(:orphan).id, workspace_id: @workspace_layer.workspace_id
        }
      }
    end

    assert_redirected_to workspace_layer_url(WorkspaceLayer.last)
  end

  test "should show workspace_layer" do
    get workspace_layer_url(@workspace_layer)
    assert_response :success
  end

  test "should get edit" do
    get edit_workspace_layer_url(@workspace_layer)
    assert_response :success
  end

  test "should update workspace_layer" do
    patch workspace_layer_url(@workspace_layer), params: {
      workspace_layer: {
        layer_id: @workspace_layer.layer_id,
        position: @workspace_layer.position,
        workspace_id: @workspace_layer.workspace_id
      }
    }
    assert_redirected_to workspace_layer_url(@workspace_layer)
  end

  test "should destroy workspace_layer" do
    assert_difference('WorkspaceLayer.count', -1) do
      delete workspace_layer_url(@workspace_layer)
    end

    assert_redirected_to workspace_layers_url
  end
end
