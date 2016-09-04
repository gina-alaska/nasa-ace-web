# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class @Workspace
  constructor: (el, channel_key) ->
    @remote = new Workspace.Remote(channel_key)
    @ui = new Workspace.UI(@, el)

    @clickable_layers = []
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
    return if !@clickable_layers.length
    features = @map.queryRenderedFeatures(e.point, { layers: @clickable_layers });
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
    @buildKeyValueHTML(properties)

  buildKeyValueHTML: (properties) =>
    html = "<table class='table table-bordered table-striped'>"
    for name, value of properties
      html += "<tr><td>#{name}</td><td>#{value}</td></tr>"
    html += "</table>"

    html

  addGeoJSONSource: (config) =>
    @map.addSource(config.name, {
      type: 'geojson',
      data: config.url
    })

  addWMSSource: (config) =>
    @map.addSource(config.name, {
      type: 'raster',
      tiles: [
        "#{config.url}?bbox={bbox-epsg-3857}&format=image/png&service=WMS&version=1.1.1&request=GetMap&srs=EPSG:3857&width=256&height=256&layers=#{config.layers}"
      ],
      tileSize: 256
    })
  addTileSource: (config) =>
    @map.addSource(config.name, {
      type: 'raster',
      tiles: [
        "#{config.url}"
      ],
      tileSize: 256
    })

  getLayerConfig: (name, next = false) ->
    return unless name?

    el = $(".layer[data-name='#{name}']")

    config = el.data()
    config.layer_name = "#{name}-layer"

    if next
      item = el.next('.layer')
      while item.length > 0
        if $(item).hasClass('active')
          config.before = @getLayerConfig($(item).data('name'), false).layer_name
          item = []
        else
          item = $(item).next('.layer')

    config

  toggleLayerFromEl: (el) =>
    name = $(el).data('name')
    if $(el).hasClass('active')
      @hideLayer(name)
    else
      @showLayer(name)
      $(el).addClass('active')

  isActiveLayer: (name) =>
    @map.getLayer(name)?

  createLayer: (name) =>
    config = @getLayerConfig(name, true)
    return config.layer_name if @isActiveLayer(config.layer_name)

    @createSource(name, config)

    layout = { 'visibility': 'visible' }
    if config.type == 'wms'
      type = 'raster'
      paint = {}
    if config.type == 'tile'
      type = 'raster'
      paint = {}
    if config.type == 'geojson'
      type = 'circle'
      paint = {
        'circle-color': 'rgba(255, 0, 0, 0.8)'
      }
      @clickable_layers.push config.layer_name

    @map.addLayer({
      id: config.layer_name,
      type: type,
      source: config.name,
      layout: layout,
      paint: paint,

    }, if @isActiveLayer(config.before) then config.before else null)

    return config.layer_name

  createSource: (name) =>
    return if @map.getSource(name)?
    config = @getLayerConfig(name)

    if config.type == 'wms'
      @addWMSSource(config)
    if config.type == 'tile'
      @addTileSource(config)
    if config.type == 'geojson'
      @addGeoJSONSource(config)
    @loading(name)
    @map.getSource(name).once('load', @loaded)

  setMoveEndHandler: () =>
    @map.on 'moveend', =>
      @remote.broadcast('move', { center: @map.getCenter(), zoom: @map.getZoom(), bearing: @map.getBearing() })

  moveTo: (data, remoteCmd = false) =>
    @map.off('moveend')
    @map.flyTo(data)
    @map.once 'moveend', @setMoveEndHandler

    # @remote.broadcast('move', data) unless remoteCmd

  reloadLayers: () =>
    activeLayers = $('.layer.active').toArray()

    for layer in activeLayers.reverse()
      name = $(layer).data('name')
      config = @getLayerConfig(name)
      @hideLayer(name)
      @showLayer(name)

  removeLayer: (name) =>
    @map.removeLayer(name)
    index = @clickable_layers.indexOf(name)
    @clickable_layers.splice(index, 1)

  hideLayer: (name, remoteCmd = false) =>
    config = @getLayerConfig(name)
    @removeLayer(config.layer_name)

    $(".layer[data-name='#{name}']").removeClass('active')
    @remote.broadcast('hideLayer', { name: name }) unless remoteCmd

  showLayer: (name, remoteCmd = false) =>
    @createLayer(name)

    $(".layer[data-name='#{name}']").addClass('active')
    @remote.broadcast('showLayer', { name: name }) unless remoteCmd

  setStyle: (style, remoteCmd = false) =>
    @reload()

    @style = "mapbox://styles/mapbox/#{style}-v9"

    @map.setStyle(@style)
    @map.style.once 'load', @onLoad

    $('.map-style.active').removeClass('active')
    $(".map-style[data-name='#{style}']").addClass('active')

    @remote.broadcast('setStyle', { name: style }) unless remoteCmd


  reload: =>
    @map.style.off 'load'
    @loading_count = 0

  onLoad: =>
    $('.layer').each (index, el) =>
      name = $(el).data('name')
      @createSource(name)
      if $(el).hasClass('active')
        @showLayer(name)

  loading: () =>
    @loading_count ||= 0
    @loading_count += 1
    $('.loading').addClass('fa-pulse')

  loaded: =>
    @loading_count ||= 0
    @loading_count -= 1
    if @loading_count <= 0
      @loading_count = 0
      $('.loading').removeClass('fa-pulse')

$(document).on 'turbolinks:load', ->
  document.workspace = new Workspace('.map-container', $('meta[name="channel_key"]').attr('content'))

  $('[data-behavior="add-layer"]').on 'click', (e) ->
    document.workspace.toggleLayerFromEl(this)
    e.preventDefault()

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
