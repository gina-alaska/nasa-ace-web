class @Workspace.Remote
  syncState: {
    movement: true,
    layers: true,
    presenter: true
  }

  commandTypes: {
    layers: ['ws.layers.show', 'ws.layers.hide', 'ws.basemap.show', 'ws.layers.reorder', 'ws.layers.adjust', 'ws.layers.delete', 'ws.layers.add'],
    movement: ['ws.view.move'],
    presenter: ['ws.presenter.request', 'ws.presenter.update', 'ws.presenter.state']
  }

  rebroadcastEvents: [
    ['ws.layers.shown', 'ws.layers.show'],
    ['ws.layers.hidden', 'ws.layers.hide'],
    ['ws.layers.deleted', 'ws.layers.delete'],
    ['ws.layers.reorder', 'ws.layers.reorder'],
    ['ws.layers.adjusted', 'ws.layers.adjust'],
    ['ws.basemap.shown', 'ws.basemap.show'],
    ['ws.presenter.requested', 'ws.presenter.request'],
    ['ws.view.moved', 'ws.view.move']
  ]

  commands: {
    move: (ws, data) ->
  }

  commandValidators: {
    move: (data) ->
      @diffLocation(@prevRemoteHash, data) && @diffLocation(@lastRemoteHash, data)
  }

  constructor: (@ws, @channel_key) ->
    @presenter = false
    @timer = new Date()
    @ignore ||= 0

    @setupEvents()

  connected: () =>
    @broadcast('ws.presenter.state')

  rebroadcast: (from, to) =>
    @ws.on from, (e, data) =>
      @broadcast(to, data)

  setupEvents: () =>
    for [from, to] in @rebroadcastEvents
      @rebroadcast(from, to)

    # special handling because we can't disable the map move event on programatic changes
    @ws.on 'ws.view.move', (e, data) =>
      @prevRemoteHash = @lastRemoteHash
      @lastRemoteHash = data

  ignoreBroadcasts: (callback) =>
    @ignore = 0 if @ignore < 0
    @ignore += 1
    callback()
    @ignore -= 1

  diffLocation: (loc1, loc2) ->
    return true if !loc1? || !loc2?
    loc1.center.lat != loc2.center.lat || loc1.center.lng != loc2.center.lng || loc1.zoom != loc2.zoom

  validateCommand: (data) =>
    if @commandValidators[data.command]?
      @commandValidators[data.command].call(@, data)
    else
      true

  received: (data) =>
    return if @myMessage(data)
    return unless @commandEnabled(data.command)
    return unless @validateCommand(data)

    @ignoreBroadcasts =>
      @ws.trigger(data.command, data)


  myMessage: (data) =>
    return data.sentBy == @channel_key

  broadcast: (name, data = {}) =>
    return if @ignore > 0
    return unless @commandEnabled(name)

    data.command = name
    data.sentBy ||= @channel_key

    App.workspaces.send(data)

  perform: (name, data = {}) =>
    App.workspaces.perform(name, data)

  commandEnabled: (command) =>
    cmdType = (type for type, cmdlist of @commandTypes when command in cmdlist)
    @is_enabled(cmdType)

  is_enabled: (type) =>
    @syncState[type]

  setSyncState: (type, state) =>
    if type == 'all'
      for name,value in @syncState
        @syncState[name] = state
    else
      @syncState[type] = state

  enable: (type = 'all') =>
    @setSyncState(type, true)

  disable: (type = 'all') =>
    @setSyncState(type, false)
