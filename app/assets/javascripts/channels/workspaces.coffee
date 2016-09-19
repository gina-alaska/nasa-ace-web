$(document).on 'turbolinks:load', ->
  App.workspaces = App.cable.subscriptions.create {
      channel: "WorkspacesChannel",
      id: $('meta[name="workspace"]').attr('content'),
      key: $('meta[name="channel_key"]').attr('content')
    },
    connected: () ->
      # Called when the subscription is ready for use on the server
      if document.workspace?
        document.workspace.remote.getPresenterState()

    disconnected: ->
      # Called when the subscription has been terminated by the server

    received: (data) ->
      # Called when there's incoming data on the websocket for this channel
      if document.workspace?
        document.workspace.runRemoteCommand(data)
