# frozen_string_literal: true
require 'test_helper'

class ViewLayersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @view_layer = view_layers(:one)
  end

  test "should get index" do
    get view_layers_url
    assert_response :success
  end

  test "should get new" do
    get new_view_layer_url
    assert_response :success
  end

  test "should create view_layer" do
    assert_difference('ViewLayer.count') do
      post view_layers_url, params: {
        view_layer: {
          layer_id: layers(:orphan).id, view_id: @view_layer.view_id
        }
      }
    end

    assert_redirected_to view_layer_url(ViewLayer.last)
  end

  test "should show view_layer" do
    get view_layer_url(@view_layer)
    assert_response :success
  end

  test "should get edit" do
    get edit_view_layer_url(@view_layer)
    assert_response :success
  end

  test "should update view_layer" do
    patch view_layer_url(@view_layer), params: {
      view_layer: {
        layer_id: @view_layer.layer_id,
        position: @view_layer.position,
        workspace_id: @view_layer.view_id
      }
    }
    assert_redirected_to view_layer_url(@view_layer)
  end

  test "should destroy view_layer" do
    assert_difference('ViewLayer.count', -1) do
      delete view_layer_url(@view_layer)
    end

    assert_redirected_to view_layers_url
  end
end
