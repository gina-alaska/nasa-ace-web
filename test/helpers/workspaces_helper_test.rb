# frozen_string_literal: true
class WorkspacesHelperTest < ActionView::TestCase
  test "overlay_icon should return for kml" do
    layer = layers(:kml)
    assert_dom_equal %{<i class="fa fa-fw fa-circle" style="color: rgba(255,0,0,0.8)"></i>}, overlay_icon(layer)
  end
  test "overlay_icon should return for geojson" do
    layer = layers(:geojson)
    assert_dom_equal %{<i class="fa fa-fw fa-circle" style="color: rgba(255,0,0,0.8)"></i>}, overlay_icon(layer)
  end
  test "overlay_icon should return for wms" do
    layer = layers(:wms)
    assert_dom_equal %(<i class="fa fa-fw fa-globe" style="color: #fff"></i>), overlay_icon(layer)
  end
  test "overlay_icon should return for tile" do
    layer = layers(:tile)
    assert_dom_equal %(<i class="fa fa-fw fa-map-o" style="color: #fff"></i>), overlay_icon(layer)
  end
end
