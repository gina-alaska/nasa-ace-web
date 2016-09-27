# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class WorkspacesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "workspaces:workspace_#{current_workspace.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    clear_presenter(params[:key])
  end

  def receive(data)
    case data["command"]
    when 'ws.layers.reorder'
      reorder_layers(data['layers'])
      rebroadcast(data)
    when 'ws.layers.show'
      update_layer_state(data['name'], { active: true })
      rebroadcast(data)
    when 'ws.layers.hide'
      update_layer_state(data['name'], { active: false })
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

  def rebroadcast(data)
    return if !current_workspace.presenter_id.blank? && current_workspace.presenter_id != params[:key]
    WorkspacesChannel.broadcast_to("workspace_#{current_workspace.id}", data)
  end

  def current_workspace
    Workspace.find(params[:id])
  end

  def update_presenter(key)
    if current_workspace.presenter_id.blank?
      current_workspace.update_attributes(presenter_id: key)
    end
    presenter_notification
  end

  def clear_presenter(key)
    if current_workspace.presenter_id == key
      current_workspace.update_attributes(presenter_id: nil)
    end
    presenter_notification
  end

  def presenter_notification
    WorkspacesChannel.broadcast_to("workspace_#{current_workspace.id}", command: 'ws.presenter.update', id: current_workspace.presenter_id)
  end

  def update_layer_state(name, state)
    layer = current_workspace.layers.where(name: name)
    wl = current_workspace.workspace_layers.where(layer: layer).first
    wl.update_attributes(state) unless wl.nil?
  end

  def reorder_layers(layers)
    layers.each_with_index do |name, index|
      layer = current_workspace.layers.where(name: name).first
      unless layer.nil?
        wl = current_workspace.workspace_layers.where(layer: layer).first
        wl.insert_at(index + 1)
      end
    end
  end
end
