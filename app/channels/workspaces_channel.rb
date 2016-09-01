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
    WorkspacesChannel.broadcast_to("workspace_#{workspace.id}", data)
  end
end
