# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class WorkspacesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "workspaces:workspace_#{current_workspace.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    unset_presenter(params[:key])
  end

  def receive(data)
    case data["command"]
    when 'reorderLayers'
      reorder_layers(data['layers'])
    when 'requestPresenter'
      request_presenter(data)
    else
      rebroadcast(data)
    end
  end

  def request_presenter(data)
    if data['state']
      set_presenter(params[:key])
    else
      unset_presenter(params[:key])
    end
  end

  def get_presenter_state
    presenter_notification
  end

  protected

  def rebroadcast(data)
    if current_workspace.presenter_id.blank? || current_workspace.presenter_id == params[:key]
      WorkspacesChannel.broadcast_to("workspace_#{current_workspace.id}", data)
    end
  end

  def current_workspace
    Workspace.find(params[:id])
  end

  def set_presenter(key)
    Rails.logger.info '*'*10
    Rails.logger.info 'set'
    if current_workspace.presenter_id.blank?
      Rails.logger.info "#{current_workspace.presenter_id} == #{key}"
      current_workspace.update_attributes(presenter_id: key)
    end
    presenter_notification
  end

  def unset_presenter(key)
    Rails.logger.info '*'*10
    Rails.logger.info 'unset'
    if current_workspace.presenter_id == key
      Rails.logger.info "#{current_workspace.presenter_id} == #{key}"
      current_workspace.update_attributes(presenter_id: nil)
    end
    presenter_notification
  end

  def presenter_notification
    WorkspacesChannel.broadcast_to("workspace_#{current_workspace.id}", { command: 'presenter', id: current_workspace.presenter_id })
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
