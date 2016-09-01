# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class RemoteWorkspace
  constructor: (@channel_key) ->
    @enable()

  hideLayer: (ws, data) ->
    return if @myMessage(data)
    ws.hideLayer(data.name, true)

  showLayer: (ws, data) ->
    return if @myMessage(data)
    ws.showLayer(data.name, true)

  move: (ws, data) ->
    return if @myMessage(data)
    # ws.moveTo(data, true)
    location.hash = data.hash

  setStyle: (ws, data) ->
    return if @myMessage(data)
    ws.setStyle(data.name, true)

  myMessage: (data) =>
    return data.sentBy == @channel_key

  broadcast: (name, data) =>
    data.command = name
    data.sentBy ||= @channel_key

    # only broadcast message if we generated the event
    App.workspaces.send(data) if @is_enabled() && @myMessage(data)

  is_enabled: () =>
    @sync

  enable: () =>
    @sync = true

  disable: () =>
    @sync = false

class Workspace
  constructor: (el, channel_key) ->
    @remote = new RemoteWorkspace(channel_key)

    @workspace = $(el)
    @clickable_layers = []
    @sidebar = $($(el).find('.map-sidebar'))
    @klass = $(@sidebar).data('class')
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

    @map.on 'moveend', (e) =>
      @remote.broadcast('move', { hash: location.hash })

    nav = new mapboxgl.Navigation({position: 'top-left'});
    @map.addControl(nav)

  runRemoteCommand: (data) =>
    return if !@remote.is_enabled() || @remote.myMessage(data)

    if @remote[data.command]?
      @remote[data.command](@, data, true)
    else
      console.log "Unknown command: #{data.command}"

  featurePopup: (e) =>
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

    if !next && el.next('.layer').length > 0
      config.before = @getLayerConfig(el.next('.layer').data('name'), true).layer_name

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
    config = @getLayerConfig(name)
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

    @map.style.once 'load', @loaded

    if config.type == 'wms'
      @addWMSSource(config)
    if config.type == 'tile'
      @addTileSource(config)
    if config.type == 'geojson'
      @addGeoJSONSource(config)
    @loading(name)

  moveTo: (data, remoteCmd = false) =>
    @remoteMove
    @map.flyTo(data)
    @remote.broadcast('move', data) unless remoteCmd

  hideLayer: (name, remoteCmd = false) =>
    layer = @createLayer(name)
    @map.setLayoutProperty(layer, 'visibility', 'none')
    $(".layer[data-name='#{name}']").removeClass('active')

    @remote.broadcast('hideLayer', { name: name }) unless remoteCmd

  showLayer: (name, remoteCmd = false) =>
    layer = @createLayer(name)
    @map.setLayoutProperty(layer, 'visibility', 'visible')
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

  loading: (name) =>
    @map.getSource(name).once('load', @loaded)
    @loading_count ||= 0
    @loading_count += 1
    $('.loading').addClass('fa-pulse')

  loaded: =>
    @loading_count ||= 0
    @loading_count -= 1
    if @loading_count <= 0
      @loading_count = 0
      $('.loading').removeClass('fa-pulse')

  expand_sidebar: =>
    @workspace.addClass(@klass)

  contract_sidebar: =>
    @workspace.removeClass(@klass)


$(document).on 'turbolinks:load', ->
  document.workspace = new Workspace('.map-container', $('meta[name="channel_key"]').attr('content'))

  $('[data-behavior="add-layer"]').on 'click', (e) ->
    document.workspace.toggleLayerFromEl(this)
    e.preventDefault()

  $('[data-toggle="workspace.sync"]').on 'click', ->
    if $(this).hasClass('active')
      $(this).removeClass('btn-success active').addClass('btn-danger')
      document.workspace.remote.disable()
    else
      $(this).removeClass('btn-danger').addClass('btn-success active')
      document.workspace.remote.enable()


  $('[data-behavior="hover-toggle"]').on 'mouseover', document.workspace.expand_sidebar
  $('[data-behavior="hover-toggle"]').on 'mouseleave', document.workspace.contract_sidebar
  $('[data-toggle="collapse"]').on 'click', ->
    caret = $(this).find('i.rotatable')
    if caret?
      caret.toggleClass('on');

  $('[data-behavior="switch-base"]').on 'click', (e) ->
    document.workspace.setStyle($(this).data('name'))

    e.preventDefault();
