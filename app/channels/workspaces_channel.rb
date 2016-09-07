# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class WorkspacesChannel < ApplicationCable::Channel
  def subscribed
    workspace = Workspace.find(params[:id])
    stream_from "workspaces:workspace_#{workspace.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    workspace = Workspace.find(params[:id])

    case data["command"]
    when 'reorderLayers'
      reorderLayers(workspace, data['layers'])
    else
      Rails.logger.info "unknown command #{data['command']}"
    end

    WorkspacesChannel.broadcast_to("workspace_#{workspace.id}", data)
  end

  def reorderLayers(workspace, layers)
    layers.each_with_index do |name, index|
      layer = workspace.layers.where(name: name).first
      unless layer.nil?
        wl = workspace.workspace_layers.where(layer: layer).first
        wl.insert_at(index + 1)
      end
    end
  end
end
