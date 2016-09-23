class @Workspace.UI
  constructor: (@ws, el) ->
    @el = @ws.el
    @sidebar = @el.find('.map-sidebar')
    @collapseClass = @sidebar.data('class')
    @overlayList = @el.find('#overlay-layer-list')

    @initEvents()

  perspective_tool: (enable) =>
    if enable
      $('[data-toggle="perspective"]').removeAttr('disabled')
    else
      $('[data-toggle="perspective"]').addClass('disabled', 'disabled')

  map_view_picker: (enable) =>
    if enable
      $('[data-behavior="map-view-picker"]').show()
    else
      $('[data-behavior="map-view-picker"]').hide()

  reset: () =>
    @loading_count = 0

  expand_sidebar: =>
    @el.addClass('open')

  contract_sidebar: =>
    @el.removeClass('open')

  initEvents: () =>
    ui = @
    ws = @ws

    @el.on 'input', '[data-adjust="opacity"]', @handleOpacity

    @el.on 'mouseover', '[data-behavior="hover-toggle"]', @expand_sidebar
    @el.on 'mouseleave', '[data-behavior="hover-toggle"]', @contract_sidebar
    @el.on 'click', '[data-toggle="collapse"]', @rotateIcon
    @el.on 'click', '[data-toggle="auto-collapse"]', @toggleAutoCollapse
    @el.on 'click', '[data-behavior="move-layer-up"]', @moveLayerUp
    @el.on 'click', '[data-behavior="move-layer-down"]', @moveLayerDown

    @el.on 'click', '[data-toggle="layer"]', (e) =>
      @toggleLayer($(e.currentTarget).parents('.layer').data('name'))
      e.preventDefault()

    @el.on 'dragstart', '.overlay-list .layer', @layerDragStart
    @el.on 'dragend', '.overlay-list .layer', @layerDragEnd
    @el.on 'dragover', '.overlay-list .layer', @layerDragOver
    @el.on 'drop', '.overlay-list .layer,.drop', @layerDrop

    @el.on 'click', '[data-toggle="presenter"]', @togglePresenter

    @el.on 'click', '[data-toggle="workspace.sync"]', (e) ->
      checkbox = $(this).find('.toggle-checkbox')

      if $(this).hasClass('active')
        $(this).removeClass('active')
        $(checkbox).removeClass('fa-check-square-o').addClass('fa-square-o')
        ws.remote.disable($(this).data('type'))
      else
        $(this).addClass('active')
        $(checkbox).addClass('fa-check-square-o').removeClass('fa-square-o')
        ws.remote.enable($(this).data('type'))

      return false

    @el.on 'click', '[data-behavior="switch-base"]', (e) ->
      ws.view.setBaseLayer($(this).data('name'))
      $('.map-style.active').removeClass('active')
      $(this).addClass('active')

      e.preventDefault();

    @el.on 'click', '[data-toggle="perspective"]', (e) ->
      return if $(this).hasClass('disabled')

      if $(this).hasClass('active')
        ws.view.map.easeTo(pitch: 0)
        $(this).removeClass('active btn-success').addClass('btn-default')
      else
        ws.view.map.easeTo(pitch: 60)
        $(this).addClass('active btn-success').removeClass('btn-default')


  setPresenter: (state) =>
    btn = $('[data-toggle="presenter"]')
    if state == true
      return if btn.hasClass('btn-success')

      $.notify('You are now the presenter', 'success')
      btn.addClass('active btn-success btn-default').removeClass('btn-default btn-warning')
    if state == false
      return if btn.hasClass('btn-warning')

      $.notify('You are no longer the presenter', 'info') if btn.hasClass('btn-success')
      $.notify('Presenter connected', 'info') if btn.hasClass('btn-default')

      btn.removeClass('active btn-success btn-default').addClass('btn-warning')
    if state == null
      return if btn.hasClass('btn-default')

      $.notify('You are no longer the presenter', 'info') if btn.hasClass('btn-success')
      $.notify('Presenter disconnected', 'info') if btn.hasClass('btn-warning')

      btn.addClass('btn-default').removeClass('btn-success btn-warning active')

  clearPresenter: () =>
    @setPresenter(null)

  togglePresenter: (e) =>
    @ws.remote.requestPresenter(!$(e.currentTarget).hasClass('active'))
    # if $(e.currentTarget).hasClass('active')

  handleOpacity: (e) =>
    value = parseInt(e.currentTarget.value, 10) / 100
    layer = $(e.currentTarget).data('layer')
    @ws.layers.setPaintProperty(layer, 'opacity', value)
    @ws.remote.broadcast('ws.layers.opacity', { name: layer, value: value })

  reorderLayerList: (layers) =>
    layerList = (@getLayer(name)[0] for name in layers)
    @overlayList.html(layerList)
    @ws.layers.reload()

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
    @ws.remote.broadcast('ws.layers.reorder', { layers: @ws.ui.getLayerList() })

  setLayerOrder: (first, second) =>
    $(second).insertAfter(first)

  moveLayerUp: (e) =>
    target = $(e.currentTarget).parents('.list-group-item')
    prev = $(target).prev()
    if prev.length > 0
      $(target).insertBefore(prev)
      @ws.trigger('ws.layers.reorder', { layers: @ws.ui.getLayerList() })

    e.preventDefault()
    e.stopPropagation()

  moveLayerDown: (e) =>
    target = $(e.currentTarget).parents('.list-group-item')
    next = $(target).next()

    if next.length > 0
      $(target).insertAfter(next)
      @ws.trigger('ws.layers.reorder', { layers: @ws.ui.getLayerList() })

    e.preventDefault()
    e.stopPropagation()

  toggleAutoCollapse: (e) =>
    btn = e.currentTarget

    if $(btn).hasClass('active')
      $(btn).removeClass('active btn-success')
      @el.addClass('auto-collapse')
    else
      $(btn).addClass('active btn-success')
      @el.removeClass('auto-collapse')


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
