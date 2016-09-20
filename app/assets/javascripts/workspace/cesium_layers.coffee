class @Workspace.CesiumLayers extends Workspace.Layers
  constructor: (@ws, @map) ->
    @_layerProviders = {}
    @_layers = {}

  providers: {
    tile: (config, callback) ->
      provider = new Cesium.UrlTemplateImageryProvider({
        url: config.url
      })
      layer = @map.imageryLayers.addImageryProvider(provider)
      callback.call(@, config, layer)

    geojson: (config, callback) ->
      @ws.ui.startLoading()
      layer = @map.dataSources.add(Cesium.GeoJsonDataSource.load(config.url, {
        # markerSymbol: 'circle',
        markerColor: Cesium.Color.fromCssColorString(config.color)
      }))

      layer.then (dataSource) =>
        @ws.ui.stopLoading()
        callback.call(@, config, dataSource)
      layer.otherwise (error) =>
        @ws.ui.stopLoading()
        $.notify(error)

      callback.call(@, config, layer)
      # promise.then((dataSource) ->
      #   layer = @map.dataSources.add(dataSource)
      #   console.log layer
      #   @ws.ui.stopLoading()
      #   callback.call(@, config, layer)
      # ).otherwise((error) ->
      #   @ws.ui.stopLoading()
      #   console.log error
      #   $.notify(error)
      # )
  }

  removeAll: () =>
    @map.imageryLayers.removeAll()
    @_layers = {}

  show: (name) =>
    @create(name)

  hide: (name) =>
    @map.imageryLayers.remove(@_layers[name])
    @map.dataSources.remove(@_layers[name])
    delete @_layers[name]

  createProviderLayer: (config, callback) =>
    @providers[config.type].call(@, config, callback) if @providers[config.type]?

  create: (name) =>
    config = @getConfig(name)
    @createProviderLayer config, (config, layer) ->
      @_layers[name] = layer
