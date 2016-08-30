# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class Workspace
  constructor: (el) ->
    @workspace = $(el)
    @clickable_layers = []
    @sidebar = $($(el).find('.map-sidebar'))
    @klass = $(@sidebar).data('class')
    @style = "mapbox://styles/mapbox/satellite-streets-v9"
    center = $(el).find('.map').data('center')
    zoom = $(el).find('.map').data('zoom')

    mapboxgl.accessToken = 'pk.eyJ1IjoiZ2luYS1hbGFza2EiLCJhIjoiN0lJVnk5QSJ9.CsQYpUUXtdCpnUdwurAYcQ';
    nav = new mapboxgl.Navigation({position: 'top-left'});
    @map = new mapboxgl.Map({
        container: 'map',
        style: @style,
        center: if center? then center else [-147.8, 64.85],
        zoom: if zoom? then zoom else 3
    });
    @map.style.on 'load', @load
    @map.on 'click', @featurePopup
    @map.addControl(nav)

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

  addGeoJSONSource: (el) =>
    @map.addSource(el.data('name'), {
      type: 'geojson',
      data: el.data('url')
    })

  addWMSSource: (el) =>
    @map.addSource(el.data('name'), {
      type: 'raster',
      tiles: [
        "#{el.data('url')}?bbox={bbox-epsg-3857}&format=image/png&service=WMS&version=1.1.1&request=GetMap&srs=EPSG:3857&width=256&height=256&layers=#{el.data('layers')}"
      ],
      tileSize: 256
    })
  addTileSource: (el) =>
    @map.addSource(el.data('name'), {
      type: 'raster',
      tiles: [
        "#{el.data('url')}"
      ],
      tileSize: 256
    })

  toggleLayerFromEl: (el) =>
    target = $(el)
    layer_name = "#{target.data('name')}-layer"
    layer = @map.getLayer(layer_name)

    if layer?
      visibility = @map.getLayoutProperty(layer_name, 'visibility')
      if visibility == 'visible'
        @hideLayer(layer_name)
      else
        @showLayer(layer_name)

      return @map.getLayoutProperty(layer_name, 'visibility') == 'visible'
    else
      @loading()
      @addLayer(target)

      source = @map.getSource(target.data('name'))
      source.on 'load', @loaded

      return true


  hideLayer: (layer) =>
    @map.setLayoutProperty(layer, 'visibility', 'none')
  showLayer: (layer) =>
    @map.setLayoutProperty(layer, 'visibility', 'visible')

  addLayer: (target) =>
    layout = { 'visibility': 'visible' }
    clickable = false

    if target.data('type') == 'wms'
      @addWMSSource(target)
      type = 'raster'
      paint = {}
    if target.data('type') == 'tile'
      @addTileSource(target)
      type = 'raster'
      paint = {}
    if target.data('type') == 'geojson'
      @addGeoJSONSource(target)
      type = 'circle'
      paint = {
        'circle-color': 'rgba(255, 0,0, 0.8)'
      }
      clickable = true

    @map.addLayer({
      id: "#{target.data('name')}-layer",
      type: type,
      source: target.data('name'),
      layout: layout,
      paint: paint
    })

    if clickable == true
      @clickable_layers.push "#{target.data('name')}-layer"

  load: =>
    $('.layer.active').each (index, el) =>
      @toggleLayerFromEl(el)

  loading: =>
    @loading_count ||= 0
    @loading_count += 1
    $('.loading').addClass('fa-pulse')

  loaded: =>
    @loading_count ||= 0
    @loading_count -= 1
    if @loading_count == 0
      $('.loading').removeClass('fa-pulse')

  expand_sidebar: =>
    @workspace.addClass(@klass)

  contract_sidebar: =>
    @workspace.removeClass(@klass)


$(document).on 'turbolinks:load', ->
  workspace = new Workspace('.map-container')

  $('[data-behavior="add-layer"]').on 'click', (e) ->
    workspace.toggleLayerFromEl(this)
    $(this).toggleClass('active')
    e.preventDefault()

  $('[data-behavior="hover-toggle"]').on 'mouseover', workspace.expand_sidebar
  $('[data-behavior="hover-toggle"]').on 'mouseleave', workspace.contract_sidebar
  $('[data-toggle="collapse"]').on 'click', ->
    caret = $(this).find('i.rotatable')
    if caret?
      caret.toggleClass('on');

  $('[data-behavior="switch-base"]').on 'click', (e) ->
    style = $(this).data('name')

    newstyle = "mapbox://styles/mapbox/#{style}-v9"

    workspace.map.setStyle(newstyle)
    workspace.style = newstyle

    workspace.map.style.on 'load', workspace.load
    $('.map-style.active').removeClass('active')
    $(this).toggleClass('active')
    e.preventDefault();
