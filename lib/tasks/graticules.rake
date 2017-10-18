# frozen_string_literal: true

namespace 'graticules' do
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
      lines << GeoRuby::GeoJSONFeature.new(line, label: format('%0.1f', long), far: (long % 10) == 0, medium: (long % 5) == 0, near: (long % 1) == 0, macro: (long % 0.5) == 0)
    end

    (-90..90).step(step) do |lat|
      points = []
      points << [-180, lat]
      points << [180, lat]
      line = GeoRuby::SimpleFeatures::LineString.from_coordinates(points, 4326)
      lines << GeoRuby::GeoJSONFeature.new(line, label: format('%0.1f', lat), far: (lat % 10) == 0, medium: (lat % 5) == 0, near: (lat % 1) == 0, macro: (lat % 0.5) == 0)
    end

    puts "{ \"type\": \"FeatureCollection\", \"features\": [#{lines.map(&:to_json).join(',')}] }"
  end
end
