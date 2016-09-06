module WorkspacesHelper
  def overlay_icon(layer)
    case layer[:type]
    when 'wms'
      symbol = 'globe'
      color = '#fff'
    when 'tile'
      symbol = 'map-o'
      color = '#fff'
    when 'geojson'
      symbol = 'circle'
      color = layer[:color]
    when 'kml'
      symbol = 'circle'
      color = layer[:color]
    end

    content_tag :i, '', class: "fa fa-fw fa-#{symbol}", style: "color: #{color}"
  end
end
