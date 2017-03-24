class @Workspace.MapboxView
  supports: {
    perspective: true
  }

  constructor: (@ws, el) ->
    mapboxgl.accessToken = 'pk.eyJ1IjoiZ2luYS1hbGFza2EiLCJhIjoiN0lJVnk5QSJ9.CsQYpUUXtdCpnUdwurAYcQ';
    @style = "mapbox://styles/mapbox/#{@ws.ui.getActiveBasemap()}-v9"
    center = $(el).find('.map').data('center')
    zoom = $(el).find('.map').data('zoom')

    @map = new mapboxgl.Map({
        container: 'map',
        style: @style,
        center: if center? then center else [-147.8, 64.85],
        zoom: if zoom? then zoom else 3
    });

    @initEvents()

    nav = new mapboxgl.Navigation({position: 'top-right'});
    @map.addControl(nav)

    draw = mapboxgl.Draw({ position: 'top-right' })
    @map.addControl(draw)

  initEvents: () =>
    @map.on 'load', @onLoad
    @map.on 'click', @featurePopup

    @ws.on 'ws.basemap.show', (e, data) =>
      @setBaseLayer(data.name)

    @ws.on 'ws.view.move', (e, data) =>
      @moveTo(data)

    @setMoveEndHandler()

  onLoad: =>
    @ws.layers.addSources()
    @ws.layers.reload()

  featurePopup: (e) =>
    return if !@ws.layers.clickable.length
    features = @map.queryRenderedFeatures(e.point, { layers: @ws.layers.clickable });
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
        html.append(content)

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
      @ws.layers.hide(name)
      $(el).removeClass('active')
    else
      @ws.layers.show(name)
      $(el).addClass('active')

  setMoveEndHandler: () =>
    @map.on 'moveend', =>
      @ws.trigger('ws.view.moved', { center: @map.getCenter(), zoom: @map.getZoom(), bearing: @map.getBearing() })

  moveTo: (data) =>
    @map.off('moveend')
    @map.flyTo(data)
    @map.once 'moveend', @setMoveEndHandler

  setBaseLayer: (name) =>
    @setStyle(name)

  setStyle: (style) =>
    @ws.reload()

    @style = "mapbox://styles/mapbox/#{style}-v9"

    @map.setStyle(@style)
    @ws.trigger('ws.basemap.shown', { name: style })

    @map.style.once 'load', () =>
      @ws.trigger('ws.layers.reload')
