class @Workspace.Mapbox.KmlLayer extends Workspace.Mapbox.GeojsonLayer
  createSource: () =>
    return if @isSourceActive()
    @map.addSource(@sourceName, {
      type: 'geojson',
      data: {
        type: 'FeatureCollection',
        features: []
      }
    })
    $.ajax(@config.url).done (xml) =>
      source = @map.getSource(@sourceName)
      source.setData toGeoJSON.kml(xml)
