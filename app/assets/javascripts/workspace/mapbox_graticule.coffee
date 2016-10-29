class @Workspace.MapboxGraticule
  constructor: (@ws) ->
    @ws.on('ws.graticule.toggle', @toggle)

    @graticule_files = ['graticule-10.geojson']
    for gratFile in @graticule_files
      @ws.view.map.addSource(gratFile, {
        type: 'geojson',
        data: "/graticules/#{gratFile}"
      })

  addGraticule: () =>
    for gratFile in @graticule_files
      @ws.view.map.addLayer({
        id: "#{gratFile}-layer",
        type: 'line',
        maxzoom: 3.5,
        source: gratFile, 
        layout: { 'visibility': 'visible' },
        paint: { 'line-color': '#aaa' }
      })
  
  toggle: () =>
    if !@ws.layers.isActive('graticule')
      @addGraticule()
