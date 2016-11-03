# frozen_string_literal: true
require 'test_helper'

class LayersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @layer = layers(:one)
  end

  test "should get index" do
    get layers_url
    assert_response :success
  end

  test "should get new" do
    get new_layer_url
    assert_response :success
  end

  test "should create layer" do
    assert_difference('Layer.count') do
      post layers_url, params: { layer: { category_id: @layer.category_id, name: @layer.name + " test", params: @layer.params, style: @layer.style, url: @layer.url } }
    end

    assert_redirected_to layer_url(Layer.last)
  end

  test "should show layer" do
    get layer_url(@layer)
    assert_response :success
  end

  test "should get edit" do
    get edit_layer_url(@layer)
    assert_response :success
  end

  test "should update layer" do
    patch layer_url(@layer), params: { layer: { category_id: @layer.category_id, name: @layer.name, params: @layer.params, style: @layer.style, url: @layer.url } }
    assert_redirected_to layer_url(@layer)
  end

  test "should destroy layer" do
    assert_difference('Layer.count', -1) do
      delete layer_url(@layer)
    end

    assert_redirected_to layers_url
  end
end
