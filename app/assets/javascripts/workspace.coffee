# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class @Workspace
  constructor: (el, channel_key) ->
    @remote = new Workspace.Remote(channel_key)
    @ui = new Workspace.UI(@, el)
    @layers = new Workspace.Layers(@)

    @style = "mapbox://styles/mapbox/satellite-streets-v9"
    center = $(el).find('.map').data('center')
    zoom = $(el).find('.map').data('zoom')

    mapboxgl.accessToken = 'pk.eyJ1IjoiZ2luYS1hbGFza2EiLCJhIjoiN0lJVnk5QSJ9.CsQYpUUXtdCpnUdwurAYcQ';

    @map = new mapboxgl.Map({
        container: 'map',
        style: @style,
        center: if center? then center else [-147.8, 64.85],
        zoom: if zoom? then zoom else 3,
        hash: true
    });

    @map.on 'load', @onLoad
    @map.on 'click', @featurePopup
    @map.on 'moveend', @setMoveEndHandler

    nav = new mapboxgl.Navigation({position: 'top-left'});
    @map.addControl(nav)

  runRemoteCommand: (data) =>
    @remote.runCommand(@, data)

  featurePopup: (e) =>
    return if !@layers.clickable.length
    features = @map.queryRenderedFeatures(e.point, { layers: @layers.clickable });
    return if !features.length

    feature = features[0]

    html = "<h5>#{features.length} features found</h5>"
    for feature in features
      html += @buildHtml(feature.properties)

    @buildPopup(feature.geometry.coordinates, html)

  buildPopup: (coordinate, html) =>
    popup = new mapboxgl.Popup()
      .setLngLat(coordinate)
      .setHTML(html)
      .addTo(@map)

  buildHtml: (properties) =>
    if properties.description
      header = "<h1>#{properties.name}</h1>"
      contents = $.parseHTML($.trim(properties.description))
      html = $("<div></div>")
      # html.append(contents)
      for content in contents
        html.append(content) unless content.nodeName == '#text'

      table = html.find('table').addClass('table table-bordered table-striped')

      header + html.html()
    else
      @buildKeyValueHTML(properties)

  buildKeyValueHTML: (properties) =>
    html = "<table class='table table-bordered table-striped'>"
    for name, value of properties
      html += "<tr><td>#{name}</td><td>#{value}</td></tr>"
    html += "</table>"

    html

  toggleLayerFromEl: (el) =>
    name = $(el).data('name')
    if $(el).hasClass('active')
      @layers.hide(name)
      $(el).removeClass('active')
    else
      @layers.show(name)
      $(el).addClass('active')

  setMoveEndHandler: () =>
    @map.on 'moveend', =>
      @remote.broadcast('move', { center: @map.getCenter(), zoom: @map.getZoom(), bearing: @map.getBearing() })

  moveTo: (data) =>
    @map.off('moveend')
    @map.flyTo(data)
    @map.once 'moveend', @setMoveEndHandler

  setStyle: (style) =>
    @reload()

    @style = "mapbox://styles/mapbox/#{style}-v9"

    @map.setStyle(@style)
    @map.style.once 'load', @onLoad

    $('.map-style.active').removeClass('active')
    $(".map-style[data-name='#{style}']").addClass('active')

    @remote.broadcast('setStyle', { name: style })

  reload: =>
    @map.style.off 'load'
    @ui.reset()

  onLoad: =>
    for el in @ui.getAllLayers()
      name = $(el).data('name')
      # preload source data
      @layers.createSource(name)
      if $(el).hasClass('active')
        @layers.show(name)

$(document).on 'turbolinks:load', ->
  document.workspace = new Workspace('.map-container', $('meta[name="channel_key"]').attr('content'))

  $('[data-toggle="workspace.sync"]').on 'click', (e) ->
    checkbox = $(this).find('.toggle-checkbox')

    if $(this).hasClass('active')
      $(this).removeClass('active')
      $(checkbox).removeClass('fa-check-square-o').addClass('fa-square-o')
      document.workspace.remote.disable($(this).data('type'))
    else
      $(this).addClass('active')
      $(checkbox).addClass('fa-check-square-o').removeClass('fa-square-o')
      document.workspace.remote.enable($(this).data('type'))

    return false

  $('[data-behavior="switch-base"]').on 'click', (e) ->
    document.workspace.setStyle($(this).data('name'))

    e.preventDefault();

  $('[data-toggle="perspective"]').on 'click', (e) ->
    if $(this).hasClass('active')
      document.workspace.map.easeTo(pitch: 0)
      $(this).removeClass('active btn-success').addClass('btn-default')
    else
      document.workspace.map.easeTo(pitch: 60)
      $(this).addClass('active btn-success').removeClass('btn-default')
