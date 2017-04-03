# frozen_string_literal: true
module LayersHelper
  def parse_layer_api_metadata(layer)
    params = { id: layer.ckan_id }
    uri = URI("http://catalog.ace.uaf.edu/api/3/action/package_show")
    uri.query = URI.encode_www_form(params)
    metadata = JSON.parse(Net::HTTP.get_response(uri).body)
    Rails.logger.info metadata["result"]['description']
    metadata["result"]
  end
end
