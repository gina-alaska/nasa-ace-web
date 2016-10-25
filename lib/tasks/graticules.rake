namespace 'graticles' do
  desc 'Build graticle geojson files for map'
  task :build, [:step] => :environment do |_t, args|
    step = args[:step].to_f

    abort "Bad step #{step}, divide evenly into 360" if (360 % step) > 0 && (360 / step) > 2

    simple_features = "MULTILINESTRING("

    lines = []
    (-180..180).step(step) do |long|
      points = []
      (-90..90).step(step) do |lat|
        points << [long, lat]
      end
      line = GeoRuby::SimpleFeatures::LineString.from_coordinates(points, 4326)
      lines << GeoRuby::GeoJSONFeature.new(line)
    end

    (-90..90).step(step) do |lat|
      points = []
      (-180..180).step(step) do |long|
        points << [long, lat]
      end
      line = GeoRuby::SimpleFeatures::LineString.from_coordinates(points, 4326)
      lines << GeoRuby::GeoJSONFeature.new(line)
    end

    puts "{ \"type\": \"FeatureCollection\", \"features\": [#{lines.map(&:to_json).join(',')}] }"
  end
end
