class @Workspace.Layers
  setup: () =>
    @map = @ws.view.map

    @ws.on 'ws.layers.reordered', (e, data) =>
      @reload()

    @ws.on 'ws.layers.opacity', (e, data) =>
      @setPaintProperty(data.name, 'opacity', data.value)

    @ws.on 'ws.layers.hide', (e, data) =>
      @hide(data.name)
    @ws.on 'ws.layers.show', (e, data) =>
      @show(data.name)

  getConfig: (name, next = false) =>
    return unless name?
    el = @ws.ui.getLayer(name)

    config = $.extend({}, el.data()) # clone the data
    config.layer_name = "#{name}-layer"

    if next
      item = el.next('.layer')
      while item.length > 0
        if $(item).hasClass('active')
          config.before = @_layerGroups[item.data('name')][0]
          item = []
        else
          item = $(item).next('.layer')

    config

  reload: () =>
    activeLayers = @ws.ui.getActiveLayers().reverse()

    for layer in activeLayers
      name = $(layer).data('name')
      @ws.remote.ignoreBroadcasts =>
        @hide(name)
        @show(name)
