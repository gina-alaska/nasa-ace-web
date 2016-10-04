@CESIUM_BASE_URL = 'http://nasa-ace-web.dev/cesium'

class @Workspace.CesiumView
  BASE_HEIGHT: 554678932

  supports: {
    perspective: false
  }

  constructor: (@ws, el) ->
    Cesium.BingMapsApi.defaultKey = 'Ah1VAfThdeX7JxKOS0BldGGAAcvjmW72i89XYRt42hc0stR5QkjCqnFKKX3MPCvg'
    Cesium.MapboxApi.defaultAccessToken = 'pk.eyJ1IjoiZ2luYS1hbGFza2EiLCJhIjoiN0lJVnk5QSJ9.CsQYpUUXtdCpnUdwurAYcQ'

    @activeBaseLayer = @ws.ui.getActiveBasemap()

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
    @initializeEvents()

  initializeEvents: () =>
    @registerMoveEndHandler()
    @ws.on 'ws.view.move', (e, data) =>
      @moveTo(data)

    @ws.on 'ws.basemap.show', (e, data) =>
      @setBaseLayer(data.name)

  registerMoveEndHandler: () =>
    if @clearRegisterMoveEnd?
      @clearRegisterMoveEnd()
      delete @clearRegisterMoveEnd

    unless @clearMoveEnd?
      # @map.camera.moveEnd.removeEventListener(@registerMoveEndHandler)
      @clearMoveEnd = @map.camera.moveEnd.addEventListener(@afterMoveEnd)

  afterMoveEnd: () =>
    center = @map.camera.positionCartographic
    heading = @map.camera.heading
    zoom = Math.max(1, Math.log2(@BASE_HEIGHT / center.height) - 4)

    @ws.trigger('ws.view.moved', { center: { lng: @radianToDegree(center.longitude), lat: @radianToDegree(center.latitude) }, zoom: zoom, bearing: @radianToDegree(@map.camera.heading) })

  radianToDegree: (value) =>
    parseFloat((value * (180/Math.PI)).toFixed(16))

  moveTo: (data) =>
    if data.zoom?
      height =  @BASE_HEIGHT / Math.pow(2, data.zoom + 4)
    if data.height?
      height = data.height

    if @clearMoveEnd?
      @clearMoveEnd()
      delete @clearMoveEnd

    # @map.camera.moveEnd.removeEventListener(@afterMoveEnd)
    @map.camera.flyTo({
      destination : Cesium.Cartesian3.fromDegrees(data.center.lng, data.center.lat, height),
      heading : data.bearing / (180/Math.PI),
      pitch : -Cesium.Math.PI_OVER_TWO,
      roll : 0.0
    })

    @clearRegisterMoveEnd = @map.camera.moveEnd.addEventListener(@registerMoveEndHandler)

  setBaseLayer: (name) =>
    layers = @map.imageryLayers
    @ws.layers.removeAll()
    layers.addImageryProvider(@getLayerProvider(name))
    @activeBaseLayer = name
    @ws.trigger('ws.layers.reload')

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
