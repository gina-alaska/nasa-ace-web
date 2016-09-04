class @Workspace.UI
  constructor: (@workspace, @el) ->
    @workspaceEl = $(@el)
    @sidebar = $(@workspaceEl.find('.map-sidebar'))
    @collapseClass = @sidebar.data('class')

    @initEvents()

  expand_sidebar: =>
    @workspaceEl.addClass('open')

  contract_sidebar: =>
    @workspaceEl.removeClass('open')

  initEvents: () =>
    ui = @
    $('[data-behavior="hover-toggle"]').on 'mouseover', @expand_sidebar
    $('[data-behavior="hover-toggle"]').on 'mouseleave', @contract_sidebar
    $('[data-toggle="collapse"]').on 'click', @rotateIcon
    $('[data-toggle="auto-collapse"]').on 'click', @toggleAutoCollapse
    $('[data-behavior="move-layer-up"]').on 'click', @moveLayerUp
    $('[data-behavior="move-layer-down"]').on 'click', @moveLayerDown
    $('.layer').on 'dragstart', @layerDragStart
    $('.layer').on 'dragend', @layerDragEnd
    $('.layer').on 'dragover', @layerDragOver
    $('.layer,.drop').on 'drop', @layerDrop

  layerDragStart: (e) =>
    @dragSrc = $(e.delegateTarget)
    @dragSrc.css('opacity', 0.4)

  layerDragEnd: (e) =>
    @dragSrc.css('opacity', 1)
    @workspace.reloadLayers()


  layerDragOver: (e) =>
    if e.preventDefault?
      @dragTarget = $(e.delegateTarget)
      @insertLayerEl(@dragTarget, @dragSrc, { x: e.clientX, y: e.clientY })
      e.preventDefault()

    return false

  insertLayerEl: (target, src, pos) =>
    offset = target.offset()
    relativeY = (pos.y - offset.top) / target.outerHeight()
    return if target.hasClass('drop')

    if relativeY >= 0.5
      $(src).insertAfter(target)
      # @setLayerOrder(target, src)
    else
      $(src).insertBefore(target)
      # @setLayerOrder(target.prev(), src)


  layerDrop: (e) =>
    @dragTarget.removeClass('over')
    @insertLayerEl(@dragTarget, @dragSrc, { x: e.clientX, y: e.clientY })

  setLayerOrder: (first, second) =>
    $(second).insertAfter(first)

  moveLayerUp: (e) =>
    target = $(e.delegateTarget).parent('.list-group-item')
    prev = $(target).prev('.list-group-item')

    if prev.length > 0
      $(target).insertBefore(prev)
      @workspace.reloadLayers()

    e.preventDefault()
    e.stopPropagation()

  moveLayerDown: (e) =>
    target = $(e.delegateTarget).parent('.list-group-item')
    next = $(target).next('.list-group-item')

    if next.length > 0
      $(target).insertAfter(next)
      @workspace.reloadLayers()

    e.preventDefault()
    e.stopPropagation()

  toggleAutoCollapse: (e) =>
    btn = e.delegateTarget

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
