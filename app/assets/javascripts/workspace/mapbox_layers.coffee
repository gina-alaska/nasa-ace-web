class @Workspace.MapboxLayers extends Workspace.Layers
  constructor: (@ws) ->
    @setup(@ws)

    @clickable = []
    @_layerList = {}

  addSources: () =>
    # for layer in @ws.ui.getAllLayers()
    #   @createSource $(layer).data('name')

  hide: (name) =>
    @remove(name)
    @ws.trigger('ws.layers.hidden', { name: name })

  show: (name) =>
    @create(name)
    @ws.trigger('ws.layers.shown', { name: name })

  isActive: (name) =>
    if @getLayer(name)?
      @getLayer(name).isActiveLayer()
    else
      @map.getLayer(name)?

  getLayer: (name) =>
    @_layerList[name]

  setPaintProperty: (name, property, value) =>
    @getLayer(name).setPaintProperty(property, value)

  create: (name) =>
    # return if @isActive(name)
    config = @getConfig(name, true)

    @_layerList[name] ||= Workspace.Mapbox.buildLayer(@ws, name, config)
    layer = @getLayer(name)

    layer.show()
    if layer.supports.click
      @clickable.push layer.sublayers...

  remove: (name, destroy = true) =>
    if @_layerList[name]?
      if @_layerList[name].supports.click
        @_layerList[name].eachSublayer (layer, index) =>
          ci = @clickable.indexOf(layer)
          @clickable.splice(ci, 1) if ci >= 0

      @_layerList[name].remove(destroy)
      delete @_layerList[name] if destroy

  loading: () =>
    @ws.ui.startLoading()

  loaded: =>
    @ws.ui.stopLoading()
