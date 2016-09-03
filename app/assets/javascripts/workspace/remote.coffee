class @Workspace.Remote
  syncState: {
    movement: true,
    layers: true
  }

  commandTypes: {
    layers: ['hideLayer', 'showLayer', 'setStyle'],
    movement: ['move']
  }

  commands: {
    hideLayer: (ws, data) ->
      ws.hideLayer(data.name, true)

    showLayer: (ws, data) ->
      ws.showLayer(data.name, true)

    move: (ws, data) ->
      location.hash = data.hash
      @prevRemoteHash = @lastRemoteHash
      @lastRemoteHash = data.hash

    setStyle: (ws, data) ->
      ws.setStyle(data.name, true)
  }

  commandValidators: {
    move: (data) ->
      @lastRemoteHash ||= ""
      @prevRemoteHash ||= ""

      @prevRemoteHash != data.hash and @lastRemoteHash != data.hash
  }

  constructor: (@channel_key) ->
    # @enable()
    @timer = new Date()

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
      @commands[data.command].call(@, ws, data)
    else
      console.log "Unknown command: #{data.command}"


  myMessage: (data) =>
    return data.sentBy == @channel_key

  broadcast: (name, data) =>
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
