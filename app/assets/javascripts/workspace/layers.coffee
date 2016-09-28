class @Workspace.Layers
  setup: () =>
    @map = @ws.view.map

    @ws.on 'ws.layers.reorder, ws.layers.reload', (e, data) =>
      @reload()

    @ws.on 'ws.layers.adjust', (e, data) =>
      if data.property == 'opacity'
        @setPaintProperty(data.layer, data.property, data.value / 100)

    @ws.on 'ws.layers.hide', (e, data) =>
      @hide(data.name)
    @ws.on 'ws.layers.show', (e, data) =>
      @show(data.name)

  getConfig: (name, next = false) =>
    return unless name?
    el = @ws.ui.getLayer(name)

    config = $.extend({}, el.data()) # clone the data
    config.layer_name = "#{name}-layer"
    config.opacity = @ws.ui.getOpacity(name) / 100

    if next
      item = el.next('.layer')
      while item.length > 0
        if $(item).hasClass('active')
          config.before = @getLayer(item.data('name'))
          item = []
        else
          item = $(item).next('.layer')

    config

  reload: () =>
    activeLayers = @ws.ui.getActiveLayers().reverse()

    for layer in activeLayers
      name = $(layer).data('name')
      @ws.remote.ignoreBroadcasts =>
        @remove(name, false)
        @show(name)
