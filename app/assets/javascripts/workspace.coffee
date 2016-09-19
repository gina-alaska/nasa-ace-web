# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class @Workspace
  constructor: (el, channel_key, view = 'cesium') ->
    @remote = new Workspace.Remote(channel_key)
    @ui = new Workspace.UI(@, el)
    if view == 'mapbox'
      @view = new Workspace.MapboxView(@, el)
      @layers = new Workspace.MapboxLayers(@, @view.map)
    else
      @view = new Workspace.CesiumView(@, el)
      @layers = new Workspace.CesiumLayers(@, @view.map)

  runRemoteCommand: (data) =>
    @remote.runCommand(@, data)

  reload: =>
    @ui.reset()

$(document).on 'turbolinks:load', ->
  document.workspace = new Workspace('.map-container', $('meta[name="channel_key"]').attr('content'))
