# frozen_string_literal: true

module ViewsHelper
  def overlay_icon(layer)
    case layer.maptype
    when 'wms'
      symbol = 'globe'
      color = '#fff'
    when 'tile'
      symbol = 'map-o'
      color = '#fff'
    when 'geojson'
      symbol = 'circle'
      color = layer.style.try(:[], 'color')
    else
      symbol = 'circle'
      color = layer.style.try(:[], 'color')
    end

    content_tag :i, '', class: "fa fa-fw fa-#{symbol}", style: "color: #{color}"
  end
end
