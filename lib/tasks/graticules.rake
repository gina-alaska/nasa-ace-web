# frozen_string_literal: true
namespace 'graticles' do
  desc 'Build graticle geojson files for map'
  task :build, [:step] => :environment do |_t, args|
    step = args[:step].to_f

    # abort "Bad step #{step}, divide evenly into 180" if (180.0.modulo(step)) > 0

    lines = []
    (-180..180).step(step) do |long|
      points = []
      points << [long, -90]
      points << [long, 90]
      line = GeoRuby::SimpleFeatures::LineString.from_coordinates(points, 4326)
      lines << GeoRuby::GeoJSONFeature.new(line, label: format('%0.3f', long))
    end

    (-90..90).step(step) do |lat|
      points = []
      points << [-180, lat]
      points << [180, lat]
      line = GeoRuby::SimpleFeatures::LineString.from_coordinates(points, 4326)
      lines << GeoRuby::GeoJSONFeature.new(line, label: format('%0.3f', lat))
    end

    puts "{ \"type\": \"FeatureCollection\", \"features\": [#{lines.map(&:to_json).join(',')}] }"
  end
end
