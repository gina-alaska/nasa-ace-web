class @Workspace.Remote
  syncState: {
    movement: true,
    layers: true
  }

  commandTypes: {
    layers: ['hideLayer', 'showLayer', 'setStyle', 'reorderLayers'],
    movement: ['move']
  }

  commands: {
    hideLayer: (ws, data) ->
      ws.layers.hide(data.name)

    showLayer: (ws, data) ->
      ws.layers.show(data.name)

    reorderLayers: (ws, data) ->
      ws.layers.reorder(data.layers)

    move: (ws, data) ->
      ws.moveTo(data)
      @prevRemoteHash = @lastRemoteHash
      @lastRemoteHash = data

    setStyle: (ws, data) ->
      ws.setStyle(data.name)
  }

  commandValidators: {
    move: (data) ->
      @diffLocation(@prevRemoteHash, data) && @diffLocation(@lastRemoteHash, data)
  }

  constructor: (@channel_key) ->
    @timer = new Date()
    @ignore ||= 0

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

  broadcast: (name, data) =>
    return if @ignore > 0
    data.command = name
    data.sentBy ||= @channel_key

    timer = new Date()
    current_time = timer.getTime()

    # need to rate limit these a bit
    if !@last_broadcast? || (current_time - @last_broadcast) > 300
      # only broadcast message if we generated the event
      if @commandEnabled(data.command) && @myMessage(data)
        App.workspaces.send(data)
        @last_broadcast = current_time

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
