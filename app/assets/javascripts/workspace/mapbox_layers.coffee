class @Workspace.MapboxLayers extends Workspace.Layers
  constructor: (@ws) ->
    @setup(@ws)

    @clickable = []
    @_layerGroups = {}

  addSources: () =>
    for layer in @ws.ui.getAllLayers()
      @createSource $(layer).data('name')

  hide: (name) =>
    @remove(name)
    @ws.trigger('ws.layers.hidden', { name: name })

  show: (name) =>
    @create(name)
    @ws.trigger('ws.layers.shown', { name: name })

  isActive: (name) =>
    if @_layerGroups[name]?
      @map.getLayer(@_layerGroups[name][0])?
    else
      @map.getLayer(name)?

  getLayer: (name, index = 0) =>
    @_layerGroups[name][index]

  setPaintProperty: (name, property, value) =>
    return unless @_layerGroups[name]
    for layer in @_layerGroups[name]
      [first,...,last] = layer.split('-')
      @map.setPaintProperty(layer, "#{last}-#{property}", value)

  addWMS: (config) =>
    beforeLayer = config.before || null
    type = 'raster'
    @addToMap({
      id: "#{config.layer_name}-#{type}",
      type: type,
      source: config.name,
      layout: { 'visibility': 'visible' },
      paint: { "#{type}-opacity": config.opacity  }
    }, beforeLayer)

  addTile: (config) =>
    beforeLayer = config.before || null
    type = 'raster'
    @addToMap({
      id: "#{config.layer_name}-#{type}",
      type: type,
      source: config.name,
      layout: { 'visibility': 'visible' },
      paint: { "#{type}-opacity": config.opacity  }
    }, beforeLayer)

  addGeoJSON: (config) =>
    beforeLayer = config.before || null
    color = config.color || randomColor()
    for type in ['circle', 'fill', 'line']
      @addToMap({
        id: "#{config.layer_name}-#{type}",
        type: type,
        source: config.name,
        layout: { 'visibility': 'visible' }
        paint: {
          "#{type}-color": color,
          "#{type}-opacity": config.opacity
        }
      }, beforeLayer, true)

  addToMap: (config, beforeLayer, clickable = false) =>
    @map.addLayer(config, beforeLayer)
    @_layerGroups[config.source] ||= []
    @_layerGroups[config.source].push(config.id)
    @clickable.push config.id

    config.id

  create: (name) =>
    return if @isActive(name)

    config = @getConfig(name, true)
    @createSource(name, config)

    layout = { 'visibility': 'visible' }
    @addWMS(config) if config.type == 'wms'
    @addTile(config) if config.type == 'tile'
    @addGeoJSON(config) if config.type == 'geojson' || config.type == 'kml'

  remove: (name, destroy = true) =>
    return unless @_layerGroups[name]?

    for layer, index in @_layerGroups[name]
      if @isActive(layer)
        @map.removeLayer(layer, destroy)
      ci = @clickable.indexOf(layer)
      @clickable.splice(ci, 1) if ci >= 0
    delete @_layerGroups[name] if destroy

  createSource: (name) =>
    return if @map.getSource(name)?
    config = @getConfig(name)

    if config.type == 'wms'
      @addWMSSource(config)
    if config.type == 'tile'
      @addTileSource(config)
    if config.type == 'geojson'
      @addGeoJSONSource(config)
    if config.type == 'kml'
      @addKMLSource(config)

  loading: () =>
    @ws.ui.startLoading()

  loaded: =>
    @ws.ui.stopLoading()

  addSource:(name, config) =>
    @loading()
    @map.addSource(name, config)
    @map.getSource(name).once('load', @loaded)

  # Layer sources
  addGeoJSONSource: (config) =>
    @addSource(config.name, {
      type: 'geojson',
      data: config.url
    })

  addWMSSource: (config) =>
    @addSource(config.name, {
      type: 'raster',
      tiles: [
        "#{config.url}?bbox={bbox-epsg-3857}&format=image/png&service=WMS&version=1.1.1&request=GetMap&srs=EPSG:3857&width=256&height=256&layers=#{config.layers}"
      ],
      tileSize: 256
    })
  addTileSource: (config) =>
    @addSource(config.name, {
      type: 'raster',
      tiles: [
        "#{config.url}"
      ],
      tileSize: 256
    })

  addKMLSource: (config) =>
    @addSource(config.name, {
      type: 'geojson',
      data: {
        type: 'FeatureCollection',
        features: []
      }
    })

    $.ajax(config.url).done (xml) =>
      source = @map.getSource(config.name)
      source.setData toGeoJSON.kml(xml)
