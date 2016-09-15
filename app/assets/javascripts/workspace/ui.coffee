class @Workspace.UI
  constructor: (@ws, @el) ->
    @workspaceEl = $(@el)
    @sidebar = $(@workspaceEl.find('.map-sidebar'))
    @collapseClass = @sidebar.data('class')
    @overlayList = $(@workspaceEl.find('#overlay-layer-list'))

    @initEvents()

  reset: () =>
    @loading_count = 0

  expand_sidebar: =>
    @workspaceEl.addClass('open')

  contract_sidebar: =>
    @workspaceEl.removeClass('open')

  initEvents: () =>
    ui = @

    $('.map-container').on 'input', '[data-adjust="opacity"]', @handleOpacity

    $('.map-container').on 'mouseover', '[data-behavior="hover-toggle"]', @expand_sidebar
    $('.map-container').on 'mouseleave', '[data-behavior="hover-toggle"]', @contract_sidebar
    $('.map-container').on 'click', '[data-toggle="collapse"]', @rotateIcon
    $('.map-container').on 'click', '[data-toggle="auto-collapse"]', @toggleAutoCollapse
    $('.map-container').on 'click', '[data-behavior="move-layer-up"]', @moveLayerUp
    $('.map-container').on 'click', '[data-behavior="move-layer-down"]', @moveLayerDown

    $('.map-container').on 'click', '[data-toggle="layer"]', (e) =>
      @toggleLayer($(e.currentTarget).parents('.layer').data('name'))
      e.preventDefault()

    $('.map-container').on 'dragstart', '.overlay-list .layer', @layerDragStart
    $('.map-container').on 'dragend', '.overlay-list .layer', @layerDragEnd
    $('.map-container').on 'dragover', '.overlay-list .layer', @layerDragOver
    $('.map-container').on 'drop', '.overlay-list .layer,.drop', @layerDrop

    $('.map-container').on 'click', '[data-toggle="presenter"]', @togglePresenter

  setPresenter: (state) =>
    if state
      $('[data-toggle="presenter"]').addClass('active btn-success').removeClass('btn-default btn-warning')
    else
      $('[data-toggle="presenter"]').removeClass('active btn-success').addClass('btn-warning')

  clearPresenter: () =>
      $('[data-toggle="presenter"]').addClass('btn-default').removeClass('btn-success btn-warning active')

  togglePresenter: (e) =>
    @ws.remote.requestPresenter(!$(e.currentTarget).hasClass('active'))
    # if $(e.currentTarget).hasClass('active')

  handleOpacity: (e) =>
    value = parseInt(e.currentTarget.value, 10) / 100
    layer = $(e.currentTarget).data('layer')
    @ws.layers.setPaintProperty(layer, 'opacity', value)
    @ws.remote.broadcast('opacity', { name: layer, value: value })

  layerDragStart: (e) =>
    @dragSrc = $(e.currentTarget)
    @dragSrc.css('opacity', 0.4)

  layerDragEnd: (e) =>
    @dragSrc.css('opacity', 1)
    @ws.layers.reload()


  layerDragOver: (e) =>
    if e.preventDefault?
      @dragTarget = $(e.currentTarget)
      @insertLayerEl(@dragTarget, @dragSrc, { x: e.clientX, y: e.clientY })
      e.preventDefault()

    return false

  insertLayerEl: (target, src, pos) =>
    offset = target.offset()
    relativeY = (pos.y - offset.top) / target.outerHeight()
    return if target.hasClass('drop')

    if relativeY >= 0.5
      $(src).insertAfter(target)
    else
      $(src).insertBefore(target)


  layerDrop: (e) =>
    @dragTarget.removeClass('over')
    @insertLayerEl(@dragTarget, @dragSrc, { x: e.clientX, y: e.clientY })
    @ws.remote.broadcast('reorderLayers', { layers: @ws.ui.getLayerList() })

  setLayerOrder: (first, second) =>
    $(second).insertAfter(first)

  moveLayerUp: (e) =>
    target = $(e.currentTarget).parents('.list-group-item')
    prev = $(target).prev()
    if prev.length > 0
      $(target).insertBefore(prev)
      @ws.layers.reload()
      @ws.remote.broadcast('reorderLayers', { layers: @ws.ui.getLayerList() })

    e.preventDefault()
    e.stopPropagation()

  moveLayerDown: (e) =>
    target = $(e.currentTarget).parents('.list-group-item')
    next = $(target).next()

    if next.length > 0
      $(target).insertAfter(next)
      @ws.layers.reload()
      @ws.remote.broadcast('reorderLayers', { layers: @ws.ui.getLayerList() })

    e.preventDefault()
    e.stopPropagation()

  toggleAutoCollapse: (e) =>
    btn = e.currentTarget

    if $(btn).hasClass('active')
      $(btn).removeClass('active btn-success')
      @workspaceEl.addClass('auto-collapse')
    else
      $(btn).addClass('active btn-success')
      @workspaceEl.removeClass('auto-collapse')


  rotateIcon: () ->
    caret = $(this).find('i.rotatable')
    if caret?
      caret.toggleClass('on');

  sidebar: () =>

  toggleLayer: (name) ->
    el = @getLayer(name)
    if $(el).hasClass('active')
      @ws.layers.hide(name)
      $(el).removeClass('active')
    else
      @ws.layers.show(name)
      $(el).addClass('active')

  getLayer: (name) ->
    $(".overlay-list .layer[data-name='#{name}']")

  getAllLayers: () ->
    $('.overlay-list .layer')

  getLayerList: () =>
    list = ($(layer).data('name') for layer in @getAllLayers())

  getActiveLayers: () ->
    $('.overlay-list .layer.active').toArray()

  startLoading: () ->
    @loading_count ||= 0
    @loading_count += 1

    $('.loading').addClass('fa-pulse')

  getOpacity: (name) =>
    parseInt(@getLayer(name).find('input[name="opacity"]')[0].value, 10) / 100

  setOpacity: (name, value) =>
    $(@getLayer(name).find('input[name="opacity"]')).val(value)

  stopLoading: () ->
    @loading_count ||= 0
    @loading_count -= 1
    if @loading_count <= 0
      @loading_count = 0
      $('.loading').removeClass('fa-pulse')
