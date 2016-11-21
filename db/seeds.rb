# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

categories = [{"name"=>"ginatile", "maptype"=>"tile", "postfix"=>"{x}/{y}/{z}"}, {"name"=>"tile", "maptype"=>"tile", "postfix"=>"{z}/{x}/{y}"}, {"name"=>"wms", "maptype"=>"wms", "postfix"=>"?bbox={bbox-epsg-3857}&format=image/png&service=WMS&version=1.1.1&request=GetMap&srs=EPSG:3857&width=256&height=256&layers={layers}"}, {"name"=>"geojson", "maptype"=>"geojson", "postfix"=>""}, {"name"=>"kml", "maptype"=>"kml", "postfix"=>""}]
Category.first_or_create(categories)

layers = [{"name"=>"GINA Best Data Layer", "url"=>"http://tiles.gina.alaska.edu/tilesrv/bdl/tile/", "params"=>"", "style"=>nil, "maptype"=>"tile"}, {"name"=>"IMIQ Sites", "url"=>"http://imiq-api.gina.alaska.edu/sites.geojson?limit=5000", "params"=>"", "style"=>{"color"=>"rgba(255, 0, 0, 0.8)"}, "maptype"=>"geojson"}, {"name"=>"GINA Orthomosaic RGB", "url"=>"http://tiles.gina.alaska.edu/tiles/SPOT5.SDMI.ORTHO_RGB/tile/", "params"=>"", "style"=>{"color"=>""}, "maptype"=>"tile"}, {"name"=>"GINA Orthomosaic CIR", "url"=>"http://tiles.gina.alaska.edu/tiles/SPOT5.SDMI.ORTHO_CIR/tile/", "params"=>"", "style"=>{"color"=>""}, "maptype"=>"tile"}, {"name"=>"GINA Topographic Maps", "url"=>"http://tiles.gina.alaska.edu/tilesrv/drg/tile/", "params"=>"", "style"=>{"color"=>""}, "maptype"=>"tile"}, {"name"=>"KML Test", "url"=>"/wc.kml", "params"=>"", "style"=>{"color"=>"rgba(86, 106, 216, 0.8)"}, "maptype"=>"kml"}]

layers.each do |config|
  layer = Layer.where(name: config['name']).first_or_initialize do |l|
    maptype = config.delete('maptype')
    l.update_attributes(config)
    l.category = Category.where(maptype: maptype).first
  end
  layer.save
end

workspace = Workspace.where(name: 'Test Workspace').first_or_create

view = workspace.views.where(name: 'Testing').first_or_create do |ws|
  ws.update_attributes(center_lat: 64.5, center_lng: -146.5, zoom: 3)
  ws.layers = Layer.all
end
view.save!
