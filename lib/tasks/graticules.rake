namespace 'graticles' do
  desc 'Build graticle geojson files for map'
  task :build, [:step] => :environment do |_t, args|
    step = args[:step].to_f

    abort "Bad step #{step}, it must be greater than 0 and not larger than 90" if step < 0.0 || step > 90.0

    simple_features = "MULTILINESTRING("

    long_save = -180.0
    lat_save = -90.0
    long_start = long_save + step
    long_end = 180 + step
    lat_start = lat_save + step

    (long_start..long_end).step(step) do |long|
      (lat_start..90.0).step(step) do |lat|
        simple_features += "(#{long_save} #{lat_save}, #{long_save} #{lat}), "
        simple_features += "(#{long_save} #{lat_save}, #{long} #{lat_save}), " unless long > 180
        lat_save = lat
      end
      simple_features += "(#{long_save} #{lat_save}, #{long} #{lat_save}), " unless long > 180
      lat_save = -90.0
      long_save = long
    end

    simple_features = simple_features.chop.chop
    simple_features += ')'

    parser = RGeo::WKRep::WKTParser.new(default_srid: 4326, strict_wkt11: true)
    geojson = parser.parse(simple_features)

    # filename = "graticle_step_by_#{step}.geojson"
    # File.open(filename, "w"){ |file| file.puts RGeo::GeoJSON.encode(geojson).to_json }

    print RGeo::GeoJSON.encode(geojson).to_json
  end
end
