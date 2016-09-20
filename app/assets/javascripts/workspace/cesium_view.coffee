@CESIUM_BASE_URL = 'http://nasa-ace-web.dev/cesium'

class @Workspace.CesiumView
  constructor: (@ws, el) ->
    Cesium.BingMapsApi.defaultKey = 'Ah1VAfThdeX7JxKOS0BldGGAAcvjmW72i89XYRt42hc0stR5QkjCqnFKKX3MPCvg'
    Cesium.MapboxApi.defaultAccessToken = 'pk.eyJ1IjoiZ2luYS1hbGFza2EiLCJhIjoiN0lJVnk5QSJ9.CsQYpUUXtdCpnUdwurAYcQ'

    @activeBaseLayer = "satellite"

    @center = $(el).find('.map').data('center')
    @zoom = $(el).find('.map').data('zoom')

    @map = new Cesium.Viewer('map', {
      baseLayerPicker: false,
      homeButton: false,
      sceneModePicker: false,
      timeline: false,
      geocode: false,
      imageryProvider: @getLayerProvider(@activeBaseLayer)
    })
    @initializeCamera()

  setBaseLayer: (name) =>
    layers = @map.imageryLayers
    @ws.layers.removeAll()
    layers.addImageryProvider(@getLayerProvider(name))
    @activeBaseLayer = name
    @ws.layers.reload()

  getLayerProvider: (name) =>
    if name == 'satellite-streets'
      name = 'satellite'

    mapId = "mapbox.#{name}"

    new Cesium.MapboxImageryProvider({
        mapId: mapId
    })

  initializeCamera: () =>
    @map.camera.flyTo({
      destination : Cesium.Cartesian3.fromDegrees(@center[0], @center[1], 15000000),
      heading : 0.0,
      pitch : -Cesium.Math.PI_OVER_TWO,
      roll : 0.0
    })
