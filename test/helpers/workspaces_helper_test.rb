class WorkspacesHelperTest < ActionView::TestCase
  test "overlay_icon should return for kml" do
    assert_dom_equal %{<i class="fa fa-fw fa-circle" style="color: rgba(255,0,0,0.8)"></i>}, overlay_icon({ type: 'kml', color: "rgba(255,0,0,0.8)" })
  end
  test "overlay_icon should return for geojson" do
    assert_dom_equal %{<i class="fa fa-fw fa-circle" style="color: rgba(255,0,0,0.8)"></i>}, overlay_icon({ type: 'geojson', color: "rgba(255,0,0,0.8)" })
  end
  test "overlay_icon should return for wms" do
    assert_dom_equal %{<i class="fa fa-fw fa-globe" style="color: #fff"></i>}, overlay_icon({ type: 'wms', color: "rgba(255,0,0,0.8)" })
  end
  test "overlay_icon should return for tile" do
    assert_dom_equal %{<i class="fa fa-fw fa-map-o" style="color: #fff"></i>}, overlay_icon({ type: 'tile', color: "rgba(255,0,0,0.8)" })
  end
end
