# frozen_string_literal: true

module LayersHelper
  def parse_layer_api_metadata(layer)
    params = { id: layer.ckan_id }
    uri = URI.parse("http://ace.rdidev.com:8080/api/3/action/package_show?id=" + layer.ckan_id)
    Rails.logger.info "Contacting uri"
    req = Net::HTTP::Get.new(uri.to_s)
    result = Net::HTTP.start(uri.host, uri.port ) {|http|
        http.request(req)
    }
    #result = Net::HTTP.get("http://ace.rdidev.com/api/3/action/package_show?id=" + layer.ckan_id)
    metadata = JSON.parse(result.body)
    Rails.logger.info "metadata = #{metadata}"
    # Rails.logger.info metadata["result"]['description']
    metadata["result"]
  end
end
