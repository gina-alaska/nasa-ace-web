class @Workspace.CesiumLayers extends Workspace.Layers
  constructor: (@ws) ->
    @setup(@ws)

    @_layerProviders = {}
    @_layers = {}

  indexOf: (layer) =>
    if layer instanceof Cesium.ImageryLayer
      @map.imageryLayers.indexOf(layer)
    else if layer instanceof Cesium.GeoJsonDataSource
      @map.dataSources.indexOf(layer)

  providers: {
    tile: (config, callback) ->
      provider = new Cesium.UrlTemplateImageryProvider({
        url: config.url
      })
      if config.before?
        index = @map.imageryLayers.indexOf(config.before)
      else
        index = null

      layer = @map.imageryLayers.addImageryProvider(provider, index)
      callback.call(@, config, layer)

    geojson: (config, callback) ->
      @ws.ui.startLoading()
      layer = @map.dataSources.add(Cesium.GeoJsonDataSource.load(config.url))

      layer.then (dataSource) =>
        for entity in dataSource.entities.values
          entity.billboard = undefined
          entity.point = new Cesium.PointGraphics({
            color: Cesium.Color.fromCssColorString(config.color),
            pixelSize: 10
          })

        @ws.ui.stopLoading()
        callback.call(@, config, dataSource)
      layer.otherwise (error) =>
        @ws.ui.stopLoading()
        $.notify(error)
  }

  setPaintProperty: (name, property, value) =>
    if property == 'opacity'
      @adjustAlpha(name, value)

  adjustAlpha: (name, value) =>
    return unless @_layers[name]?

    if @_layers[name] instanceof Cesium.ImageryLayer
      @_layers[name].alpha = value
    if @_layers[name] instanceof Cesium.GeoJsonDataSource
      config = @getConfig(name)
      color = Cesium.Color.fromCssColorString(config.color)
      color.withAlpha(value, color)
      outlineColor = Cesium.Color.BLACK.withAlpha(value)

      for entity in @_layers[name].entities.values
        entity.point.color = color
        entity.point.outlineColor = outlineColor

  removeAll: () =>
    @map.imageryLayers.removeAll()
    @_layers = {}

  show: (name) =>
    @create(name)

    if @layerDefined(name)
      if !@getLayer(name).show
        @getLayer(name).show = true
      if !@isActive(name)
        @add(name)


  hide: (name) =>
    @remove(name, false)

  layerDefined: (name) =>
    @getLayer(name)?

  add: (name) =>
    return unless @layerDefined(name)

    layer = @getLayer(name)
    config = @getConfig(name, true)

    if layer instanceof Cesium.ImageryLayer
      @map.imageryLayers.add(layer, @indexOf(config.before))
    if layer instanceof Cesium.GeoJsonDataSource
      @map.dataSources.add(layer, @indexOf(config.before))

  remove: (name, destroy = true) =>
    @map.imageryLayers.remove(@_layers[name], destroy)
    @map.dataSources.remove(@_layers[name], destroy)
    delete @_layers[name] if destroy

  isActive: (name) =>
    layer = @getLayer(name)
    layer && (@map.imageryLayers.contains(layer) || @map.dataSources.contains(layer))

  getLayer: (name) =>
    @_layers[name]

  setLayer: (name, layer) =>
    @_layers[name] ||= layer

  createProviderLayer: (config, callback) =>
    @providers[config.type].call(@, config, callback) if @providers[config.type]?

  create: (name) =>
    return if @layerDefined(name)
    config = @getConfig(name, true)
    @createProviderLayer config, (config, layer) ->
      layer.show = true
      @setLayer(name, layer)
      @adjustAlpha(name, config.opacity)
      @ws.trigger('ws.layers.shown', { name: name })
