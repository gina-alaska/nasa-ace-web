class @Workspace.Remote
  syncState: {
    movement: true,
    layers: true,
    presenter: true
  }

  commandTypes: {
    layers: ['ws.layers.show', 'ws.layers.hide', 'setStyle', 'ws.layers.reorder', 'ws.layers.opacity'],
    movement: ['move'],
    presenter: ['requestPresenter', 'presenter']
  }

  commands: {
    "ws.layers.hide": (ws, data) ->
      ws.layers.hide(data.name)

    "ws.layers.show": (ws, data) ->
      ws.layers.show(data.name)

    "ws.layers.reorder": (ws, data) ->
      ws.ui.reorderLayerList(data.layers)

    "ws.layers.opacity": (ws, data) ->
      ws.ui.setOpacity(data.name, data.value * 100)
      ws.layers.setPaintProperty(data.name, 'opacity', data.value)

    move: (ws, data) ->
      ws.view.moveTo(data)
      @prevRemoteHash = @lastRemoteHash
      @lastRemoteHash = data

    setStyle: (ws, data) ->
      ws.view.setStyle(data.name)

    presenter: (ws, data) ->
      if data.id == null
        ws.ui.clearPresenter()
      else if data.id == ws.remote.channel_key
        ws.ui.setPresenter(true)
      else
        ws.ui.setPresenter(false)
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

  setupEvents: () =>
    @ws.on 'ws.layers.show', (e, data) =>
      @broadcast('ws.layers.show', data)

    @ws.on 'ws.layers.hide', (e, data) =>
      @broadcast('ws.layers.hide', data)

    @ws.on 'ws.layers.reorder', (e, data) =>
      @broadcast('ws.layers.reorder', data)

    @ws.on 'ws.layers.opacity', (e, data) =>
      @broadcast('ws.layers.opacity', data)


  requestPresenter: (state = true) =>
    @broadcast('requestPresenter', { "state": state })

  getPresenterState: () =>
    @perform('presenter_state')

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

  runCommand: (ws, data) =>
    return if @myMessage(data)
    return unless @commandEnabled(data.command)
    return unless @validateCommand(data)

    if @commands[data.command]?
      @ignoreBroadcasts =>
        @commands[data.command].call(@, ws, data)
    else
      console.log "Unknown command: #{data.command}"


  myMessage: (data) =>
    return data.sentBy == @channel_key

  broadcast: (name, data = {}) =>
    return if @ignore > 0
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
