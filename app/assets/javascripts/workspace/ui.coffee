class @Workspace.UI
  constructor: (@el) ->
    @workspace = $(@el)
    @sidebar = $(@workspace.find('.map-sidebar'))
    @collapseClass = @sidebar.data('class')

    @initEvents()

  expand_sidebar: =>
    @workspace.addClass('open')

  contract_sidebar: =>
    @workspace.removeClass('open')

  initEvents: () =>
    $('[data-behavior="hover-toggle"]').on 'mouseover', @expand_sidebar
    $('[data-behavior="hover-toggle"]').on 'mouseleave', @contract_sidebar
    $('[data-toggle="collapse"]').on 'click', @rotateIcon
    $('[data-toggle="auto-collapse"]').on 'click', @toggleAutoCollapse

  toggleAutoCollapse: (e) =>
    btn = e.delegateTarget

    if $(btn).hasClass('active')
      $(btn).removeClass('active btn-success')
      @workspace.addClass('auto-collapse')
    else
      $(btn).addClass('active btn-success')
      @workspace.removeClass('auto-collapse')


  rotateIcon: () ->
    caret = $(this).find('i.rotatable')
    if caret?
      caret.toggleClass('on');

  sidebar: () =>
