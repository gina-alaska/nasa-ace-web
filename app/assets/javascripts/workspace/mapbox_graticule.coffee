class @Workspace.MapboxGraticule
  constructor: (@ws, @map) ->
    @ws.on 'ws.graticule.toggle', @toggle
    # @ws.on 'ws.view.loaded', @reload
    @ws.on 'ws.layers.reorder', @reload
    @ws.on 'ws.layers.reload', @reload

    @graticule_files = [
      {
      name: 'graticule-10.geojson'
      minzoom: 0
      maxzoom: 3
      },
      {
      name: 'graticule-5.geojson'
      minzoom: 3
      maxzoom: 5
      },
      {
      name: 'graticule-1.geojson'
      minzoom: 5
      maxzoom: 7
      },
      {
      name: 'graticule-02.geojson'
      minzoom: 7
      maxzoom: 9
      },
      {
      name: 'graticule-04.geojson'
      minzoom: 9
      maxzoom: 11
      },
      {
      name: 'graticule-08.geojson'
      minzoom: 11
      maxzoom: 15
      }
    ]

  reload: () =>
    if @isActive()
      @add(@map)
    else
      @remove(@map)

  add: (map) =>
    for gratFile in @graticule_files
      if !@map.getSource(gratFile['name'])?
        @map.addSource(gratFile['name'], {
          type: 'geojson',
          data: "/graticules/#{gratFile['name']}"
        })

      if !@ws.layers.isActive("#{gratFile['name']}-layer")
        map.addLayer({
          id: "#{gratFile['name']}-layer",
          type: 'line',
          minzoom: gratFile['minzoom'],
          maxzoom: gratFile['maxzoom'],
          source: gratFile['name'],
          layout: { 'visibility': 'visible' },
          paint: { 'line-color': '#aaa' }
        })
        map.addLayer({
          id: "#{gratFile['name']}-label",
          type: 'symbol',
          minzoom: gratFile['minzoom'],
          maxzoom: gratFile['maxzoom'],
          source: gratFile['name'],
          layout: { 'text-field': '{label}', 'symbol-placement': 'line', 'text-anchor': 'bottom', 'text-size': 12 },
          paint: { 'text-color': 'rgba(255,255,255,0.8)', 'text-halo-color': 'rgba(0,0,0,0.5)', 'text-halo-width': 2 }
        })

    @ws.trigger('ws.graticule.shown')

  isActive: () =>
    @ws.ui.getGraticule().hasClass('active')

  toggle: () =>
    if !@isActive()
      @add(@map)
    else
      @remove(@map)

  remove: (map) =>
    for gratFile in @graticule_files
      if @ws.layers.isActive("#{gratFile['name']}-layer")
        map.removeLayer("#{gratFile['name']}-layer")
        map.removeLayer("#{gratFile['name']}-label")

    @ws.trigger('ws.graticule.hidden')