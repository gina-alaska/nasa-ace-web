class @Workspace.Layers
  setup: () =>
    @map = @ws.view.map

    @ws.on 'ws.layers.reorder', (e, data) =>
      @reload()


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
