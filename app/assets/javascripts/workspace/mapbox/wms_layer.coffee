class @Workspace.Mapbox.WmsLayer extends Workspace.Mapbox.Layer
  supports: {
    click: false
  }

  createSource: () =>
    @map.addSource(@sourceName, {
      type: 'raster',
      tiles: [ @config.url.replace('{layers}', @config.params) ],
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
