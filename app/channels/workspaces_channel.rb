# frozen_string_literal: true
# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class WorkspacesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "workspaces:#{channel_name}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    clear_presenter(params[:key])
  end

  def receive(data)
    case data["command"]
    when 'ws.basemap.show'
      update_workspace_state(basemap: data['name'])
      rebroadcast(data)
    when 'ws.layers.reorder'
      reorder_layers(data['layers'])
      rebroadcast(data)
    when 'ws.layers.delete'
      # TODO: Implement deletion of layer from the view
      rebroadcast(data)
    when 'ws.layers.show'
      update_layer_state(data['name'], active: true)
      rebroadcast(data)
    when 'ws.layers.hide'
      update_layer_state(data['name'], active: false)
      rebroadcast(data)
    when 'ws.presenter.request'
      request_presenter(data)
    when 'ws.presenter.state'
      presenter_notification
    else
      rebroadcast(data)
    end
  end

  def request_presenter(data)
    if data['state']
      update_presenter(params[:key])
    else
      clear_presenter(params[:key])
    end
  end

  protected

  def channel_name
    "workspace_#{current_workspace.id}_#{current_view.id}"
  end

  def rebroadcast(data)
    return if !current_view.presenter_id.blank? && current_view.presenter_id != params[:key]
    WorkspacesChannel.broadcast_to(channel_name, data)
  end

  def current_workspace
    Workspace.find(params[:id])
  end

  def current_view
    current_workspace.views.find(params[:view_id])
  end

  def update_presenter(key)
    if current_view.presenter_id.blank?
      current_view.update_attributes(presenter_id: key)
    end
    presenter_notification
  end

  def clear_presenter(key)
    if current_view.presenter_id == key
      current_view.update_attributes(presenter_id: nil)
    end
    presenter_notification
  end

  def presenter_notification
    WorkspacesChannel.broadcast_to(channel_name, command: 'ws.presenter.update', id: current_view.presenter_id)
  end

  def update_layer_state(name, state = {})
    layer = current_view.layers.where(name: name)
    wl = current_view.view_layers.where(layer: layer).first
    wl.update_attributes(state) unless wl.nil?
  end

  def update_workspace_state(state = {})
    current_view.update_attributes(state)
  end

  def reorder_layers(layers)
    layers.each_with_index do |name, index|
      layer = current_view.layers.where(name: name).first
      unless layer.nil?
        wl = current_view.view_layers.where(layer: layer).first
        wl.insert_at(index + 1)
      end
    end
  end
end
