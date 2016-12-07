class @Workspace.Mapbox.WmsLayer extends Workspace.Mapbox.Layer
  supports: {
    click: false
  }

  createSource: () =>
    @map.addSource(@sourceName, {
      type: 'raster',
      tiles: [
        "#{@config.url}?bbox={bbox-epsg-3857}&format=image/png&service=WMS&version=1.1.1&request=GetMap&srs=EPSG:3857&width=256&height=256&layers=#{@config.layers}"
      ],
      tileSize: 256
    })

  createLayers: () =>
    beforeLayer = @config.before || null
    type = 'raster'
    
    @addToMap({
      id: "#{@name}-#{type}",
      type: type,
      source: @sourceName,
      layout: { 'visibility': 'visible' },
      paint: { "#{type}-opacity": @config.opacity  }
    }, beforeLayer)
