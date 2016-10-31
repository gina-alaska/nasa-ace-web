class @Workspace.MapboxGraticule
  constructor: (@ws, @map) ->
    @ws.on('ws.graticule.toggle', @toggle)

    @graticule_files = [
      {
      name: 'graticule-10.geojson'
      minzoom: 0
      maxzoom: 4
      },
      {
      name: 'graticule-5.geojson'
      minzoom: 4
      maxzoom: 6
      },
      {
      name: 'graticule-1.geojson'
      minzoom: 6
      maxzoom: 8
      },
      {
      name: 'graticule-02.geojson'
      minzoom: 8
      maxzoom: 10
      }
    ]

    for gratFile in @graticule_files
      @map.addSource(gratFile['name'], {
        type: 'geojson',
        data: "/graticules/#{gratFile['name']}"
      })

  add: (map) =>
    for gratFile in @graticule_files
      map.addLayer({
        id: "#{gratFile['name']}-layer",
        type: 'line',
        minzoom: gratFile['minzoom'],
        maxzoom: gratFile['maxzoom'],
        source: gratFile['name'], 
        layout: { 'visibility': 'visible' },
        paint: { 'line-color': '#aaa' }
      })
    @ws.trigger('ws.graticule.shown')
  
  toggle: () =>
    if !@ws.layers.isActive("#{@graticule_files[0]['name']}-layer")
      @add(@map)
    else
      @remove(@map)

  remove: (map) =>
    for gratFile in @graticule_files
      map.removeLayer("#{gratFile['name']}-layer")
    @ws.trigger('ws.graticule.hidden')
    
