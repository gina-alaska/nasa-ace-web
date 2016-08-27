# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class Workspace
  constructor: (el) ->
    @workspace = $(el)
    @sidebar = $($(el).find('.map-sidebar'))
    @klass = $(@sidebar).data('class')
    @style = "mapbox://styles/mapbox/satellite-streets-v9"

    mapboxgl.accessToken = 'pk.eyJ1IjoiZ2luYS1hbGFza2EiLCJhIjoiN0lJVnk5QSJ9.CsQYpUUXtdCpnUdwurAYcQ';
    nav = new mapboxgl.Navigation({position: 'top-left'});
    @map = new mapboxgl.Map({
        container: 'map',
        style: @style,
        center: [-147.8, 64.85],
        zoom: 3
    });
    @map.style.on 'load', @load
    @map.addControl(nav)

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
      console.log visibility
      if visibility == 'visible'
        @hideLayer(layer_name)
      else
        @showLayer(layer_name)

      return @map.getLayoutProperty(layer_name, 'visibility') == 'visible'
    else
      @addLayer(target)
      return true


  hideLayer: (layer) =>
    @map.setLayoutProperty(layer, 'visibility', 'none')
  showLayer: (layer) =>
    @map.setLayoutProperty(layer, 'visibility', 'visible')
    console.log 'test'

  addLayer: (target) =>
    layout = { 'visibility': 'visible' }
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

    @map.addLayer({
      id: "#{target.data('name')}-layer",
      type: type,
      source: target.data('name'),
      layout: layout,
      paint: paint
    })

  load: =>
    $('.layer.active').each (index, el) =>
      @toggleLayerFromEl(el)

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
