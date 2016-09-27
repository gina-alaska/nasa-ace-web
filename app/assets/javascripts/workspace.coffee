# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class @Workspace
  supports: {
    'cesium': true
  }

  constructor: (el, channel_key, view = 'cesium') ->
    @el = $(el)
    return unless @el.length > 0

    @remote = new Workspace.Remote(@, channel_key)
    @ui = new Workspace.UI(@, el)
    if view == '3d' && @supports.cesium
      @view = new Workspace.CesiumView(@, el)
      @layers = new Workspace.CesiumLayers(@, @view.map)
    else
      @view = new Workspace.MapboxView(@, el)
      @layers = new Workspace.MapboxLayers(@, @view.map)

    @ui.perspective_tool(@view.supports.perspective)
    @ui.map_view_picker(@supports.cesium)

  reload: =>
    @ui.reset()

  on: (event, data) =>
    @el.on(event, data)

  trigger: (event, data) =>
    @el.trigger(event, data)

$(document).on 'turbolinks:load', ->
  document.workspace = new Workspace(
                              '.map-container',
                              $('meta[name="channel_key"]').attr('content'),
                              $('meta[name="map_view"]').attr('content')
                           )
