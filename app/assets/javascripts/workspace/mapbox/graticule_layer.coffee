# Class for handling single instance of a layer

class @Workspace.Mapbox.GraticuleLayer extends Workspace.Mapbox.Layer
  supports: {
    click: false
  }

  createSource: () =>
    @map.addSource(@sourceName, {
      type: 'geojson',
      data: @config.url
    })

  createLayers: () =>
    layers = [['far', 0, 4], ['medium', 4, 7], ['near', 7, 9], ['macro', 9, 22]]
    for config in layers
      [level, minz, maxz] = config
      @addToMap({
        id: "#{@name}-#{level}-layer",
        type: 'line',
        source: @sourceName,
        filter: ["==", level, true],
        minzoom: minz,
        maxzoom: maxz,
        layout: { 'visibility': 'visible' },
        paint: { 'line-color': '#aaa' }
      })
      @addToMap({
        id: "#{@name}-#{level}-label",
        type: 'symbol',
        source: @sourceName,
        filter: ["==", level, true],
        minzoom: minz,
        maxzoom: maxz,
        layout: { 'text-field': '{label}', 'symbol-placement': 'line', 'text-anchor': 'bottom', 'text-size': 12 },
        paint: { 'text-color': 'rgba(255,255,255,0.8)', 'text-halo-color': 'rgba(0,0,0,0.5)', 'text-halo-width': 2 }
      })
