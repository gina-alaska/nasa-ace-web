@CESIUM_BASE_URL = 'http://nasa-ace-web.dev/cesium'

class @Workspace.CesiumView
  constructor: (@ws, el) ->
    Cesium.MapboxApi.defaultAccessToken = 'pk.eyJ1IjoiZ2luYS1hbGFza2EiLCJhIjoiN0lJVnk5QSJ9.CsQYpUUXtdCpnUdwurAYcQ'

    @activeBaseLayer = "satellite"

    @baseLayers = {}


    @center = $(el).find('.map').data('center')
    @zoom = $(el).find('.map').data('zoom')

    @map = new Cesium.Viewer('map', {
      baseLayerPicker: false,
      imageryProvider: @getBaseLayer(@activeBaseLayer)
    })
    @initializeCamera()

  setBaseLayer: (name) =>
    layers = @map.imageryLayers
    layers.removeAll()
    layers.addImageryProvider(@getBaseLayer(name))
    @activeBaseLayer = name

  getBaseLayer: (name) =>
    if name == 'satellite-streets'
      name = 'satellite'
      
    mapId = "mapbox.#{name}"

    @baseLayers[name] ||= new Cesium.MapboxImageryProvider({
        mapId: mapId
    })

    @baseLayers[name]

  initializeCamera: () =>
    @map.camera.flyTo({
      destination : Cesium.Cartesian3.fromDegrees(@center[0], @center[1], 15000000),
      heading : 0.0,
      pitch : -Cesium.Math.PI_OVER_TWO,
      roll : 0.0
    })
