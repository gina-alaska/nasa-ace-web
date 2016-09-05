class @Workspace.Layers
  constructor: (@ws) ->
    @clickable = []

  reorder: (layers) =>
    layerList = (@ws.ui.getLayer(name)[0] for name in layers)
    @ws.ui.overlayList.html(layerList)
    @reload()

  reload: () =>
    activeLayers = @ws.ui.getActiveLayers().reverse()

    for layer in activeLayers
      name = $(layer).data('name')
      config = @getConfig(name)
      @ws.remote.ignoreBroadcasts =>
        @hide(name)
        @show(name)

  hide: (name) =>
    config = @getConfig(name)
    @remove(config.layer_name)

    @ws.ui.getLayer(name).removeClass('active')
    @ws.remote.broadcast('hideLayer', { name: name })

  show: (name) =>
    @create(name)

    @ws.ui.getLayer(name).addClass('active')
    @ws.remote.broadcast('showLayer', { name: name })


  getConfig: (name, next = false) ->
    return unless name?

    el = @ws.ui.getLayer(name)

    config = $.extend({}, el.data()) # clone the data
    config.layer_name = "#{name}-layer"

    if next
      item = el.next('.layer')
      while item.length > 0
        if $(item).hasClass('active')
          config.before = @getConfig($(item).data('name'), false).layer_name
          item = []
        else
          item = $(item).next('.layer')

    config

  isActive: (name) =>
    @ws.map.getLayer(name)?

  create: (name) =>
    config = @getConfig(name, true)
    return config.layer_name if @isActive(config.layer_name)

    @createSource(name, config)

    layout = { 'visibility': 'visible' }
    if config.type == 'wms'
      type = 'raster'
      paint = {}
    if config.type == 'tile'
      type = 'raster'
      paint = {}
    if config.type == 'geojson'
      type = 'circle'
      paint = {
        'circle-color': 'rgba(255, 0, 0, 0.8)'
      }
      @clickable.push config.layer_name
    if config.type == 'kml'
      type = 'circle'
      paint = {
        'circle-color': 'rgba(50, 50, 255, 0.8)'
      }
      @clickable.push config.layer_name

    beforeLayer = config.before || null

    @ws.map.addLayer({
      id: config.layer_name,
      type: type,
      source: config.name,
      layout: layout,
      paint: paint,

    }, beforeLayer)

    return config.layer_name

  remove: (name) =>
    @ws.map.removeLayer(name)
    index = @clickable.indexOf(name)
    @clickable.splice(index, 1) if index >= 0

  createSource: (name) =>
    return if @ws.map.getSource(name)?
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
    @ws.map.addSource(name, config)
    @ws.map.getSource(name).once('load', @loaded)

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
      source = @ws.map.getSource(config.name)
      source.setData toGeoJSON.kml(xml)
