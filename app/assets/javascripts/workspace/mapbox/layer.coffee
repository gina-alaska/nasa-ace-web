# Class for handling single instance of a layer

class @Workspace.Mapbox.Layer
  supports: {
    click: false
  }

  constructor: (@map, @name, @config) ->
    @sublayers = []
    @sourceName = "#{@name}-source"

  createSource: () =>
    throw 'createSource method not implemented'

  createLayers: () =>
    throw 'createLayers method not implemented'

  getSublayer: (index) =>
    @sublayers[index]

  show: () =>
    @createSource() unless @isSourceActive()
    @createLayers() unless @isLayerActive()

  hide: () =>
    @remove()

  eachSublayer: (callback) =>
    for layer, index in @sublayers
      callback(layer, index)

  setPaintProperty: (property, value) =>
    return unless @isLayerActive()
    @eachSublayer (layer, index) =>
      @setOpacity(layer, value) if property == 'opacity'

  setOpacity: (layer, value) ->
    type = @map.getLayer(layer).type
    if type in ['circle', 'line', 'fill']
      @map.setPaintProperty(layer, "#{type}-opacity", value)
    if type in ['symbol']
      @map.setPaintProperty(layer, "text-opacity", value)

  isLayerActive: () =>
    @map.getLayer(@getSublayer(0))?

  isSourceActive: () =>
    @map.getSource(@sourceName)? if @sourceName?

  remove: (destroy = true) =>
    @eachSublayer (layer, index) =>
      @map.removeLayer(layer, destroy)
    @sublayers = []

  addToMap: (config, before) =>
    return if @map.getLayer(config.id)?
    @sublayers.push(config.id)
    @map.addLayer(config, before)
