# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class WorkspacesChannel < ApplicationCable::Channel
  def subscribed
    workspace = Workspace.find(params[:id])
    stream_from "workspaces:workspace_#{workspace.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    workspace = Workspace.find(params[:id])
    if workspace.presenter_id == params[:key]
      workspace.update_attributes(presenter_id: nil)
    end
  end

  def receive(data)
    workspace = Workspace.find(params[:id])

    case data["command"]
    when 'reorderLayers'
      reorder_layers(workspace, data['layers'])
    when 'requestPresenter'
      request_presenter(data)
    end

    if workspace.presenter_id.nil? || workspace.presenter_id == params[:key]
      WorkspacesChannel.broadcast_to("workspace_#{workspace.id}", data)
    end
  end

  def request_presenter(data)
    workspace = Workspace.find(params[:id])

    if data['state']
      presenter = set_presenter(workspace)
    else
      presenter = unset_presenter(workspace)
    end

    WorkspacesChannel.broadcast_to("workspace_#{workspace.id}", { command: 'presenter', id: presenter })
  end

  protected

  def set_presenter(workspace)
    if workspace.presenter_id.nil? || workspace.presenter_id == params[:key]
      workspace.update_attributes(presenter_id: params[:key])
    end

    workspace.presenter_id
  end

  def unset_presenter(workspace)
    if workspace.presenter_id.nil? || workspace.presenter_id == params[:key]
      workspace.update_attributes(presenter_id: nil)
    end

    workspace.presenter_id
  end

  def reorder_layers(workspace, layers)
    layers.each_with_index do |name, index|
      layer = workspace.layers.where(name: name).first
      unless layer.nil?
        wl = workspace.workspace_layers.where(layer: layer).first
        wl.insert_at(index + 1)
      end
    end
  end
end
