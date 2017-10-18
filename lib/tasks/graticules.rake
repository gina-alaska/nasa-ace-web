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
      lines << GeoRuby::GeoJSONFeature.new(line, label: format('%0.1f', long), far: (long % 10).zero?, medium: (long % 5).zero?, near: (long % 1).zero?, macro: (long % 0.5).zero?)
    end

    (-90..90).step(step) do |lat|
      points = []
      points << [-180, lat]
      points << [180, lat]
      line = GeoRuby::SimpleFeatures::LineString.from_coordinates(points, 4326)
      lines << GeoRuby::GeoJSONFeature.new(line, label: format('%0.1f', lat), far: (lat % 10).zero?, medium: (lat % 5).zero?, near: (lat % 1).zero?, macro: (lat % 0.5).zero?)
    end

    puts "{ \"type\": \"FeatureCollection\", \"features\": [#{lines.map(&:to_json).join(',')}] }"
  end
end
