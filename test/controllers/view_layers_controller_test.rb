# frozen_string_literal: true
require 'test_helper'

class ViewLayersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workspace = workspaces(:one)
    @view_layer = view_layers(:one)
    @view = @view_layer.view
  end

  test "should get index" do
    get workspace_view_view_layers_url(@workspace, @view)
    assert_response :success
  end

  test "should get new" do
    get new_workspace_view_view_layer_url(@workspace, @view)
    assert_response :success
  end

  test "should create view_layer" do
    assert_difference('ViewLayer.count') do
      post workspace_view_view_layers_url(@workspace, @view), params: {
        view_layer: {
          layer_id: layers(:orphan).id, view_id: @view_layer.view_id
        }
      }
    end

    assert_redirected_to workspace_view_view_layer_url(@workspace, @view, ViewLayer.last)
  end

  test "should show view_layer" do
    get workspace_view_view_layer_url(@workspace, @view, @view_layer)
    assert_response :success
  end

  test "should get edit" do
    get edit_workspace_view_view_layer_url(@workspace, @view, @view_layer)
    assert_response :success
  end

  test "should update view_layer" do
    patch workspace_view_view_layer_url(@workspace, @view, @view_layer), params: {
      view_layer: {
        layer_id: @view_layer.layer_id,
        position: @view_layer.position,
        workspace_id: @view_layer.view_id
      }
    }
    assert_redirected_to workspace_view_view_layer_url(@workspace, @view, @view_layer)
  end

  test "should destroy view_layer" do
    assert_difference('ViewLayer.count', -1) do
      delete workspace_view_view_layer_url(@workspace, @view, @view_layer)
    end

    assert_redirected_to workspace_view_url(@workspace, @view)
  end
end
