class @Workspace.Mapbox.GeojsonLayer extends Workspace.Mapbox.Layer
  supports: {
    click: true
  }

  createSource: () =>
    return if @isSourceActive()

    @map.addSource(@sourceName, {
      type: 'geojson',
      data: @config.url
    })

  createLayers: () =>
    @sublayers = []

    beforeLayer = @config.before || null
    color = @config.color || randomColor()
    for type in ['circle', 'fill', 'line']
      @addToMap({
        id: "#{@name}-#{type}",
        type: type,
        source: @sourceName,
        layout: { 'visibility': 'visible' }
        paint: {
          "#{type}-color": color,
          "#{type}-opacity": @config.opacity
        }
      }, beforeLayer)
