@Workspace.Mapbox = {
  buildLayer: (map, name, config) ->
    if config.type == 'geojson'
      return new Workspace.Mapbox.GeojsonLayer(map, name, config)
    if config.type == 'kml'
      return new Workspace.Mapbox.KmlLayer(map, name, config)
    if config.type == 'wms'
      return new Workspace.Mapbox.WmsLayer(map, name, config)
    if config.type == 'tile'
      return new Workspace.Mapbox.TileLayer(map, name, config)
    if config.type == 'graticule'
      return new Workspace.Mapbox.GraticuleLayer(map, name, config)
}
