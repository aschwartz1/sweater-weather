class MapService
  def self.fetch_geocoords(location)
    response = map_connection.get('address') do |req|
      req.params[:location] = location
    end

    format_map_response(response)
  end

  def self.map_connection
    @map_connection ||= Faraday.new 'http://www.mapquestapi.com/geocoding/v1' do |conn|
      conn.params[:key] = ENV['mapquest_key']
    end
  end

  def self.format_map_response(response)
    body = JSON.parse(response.body, symbolize_names: true)
    geocoords = body[:results].first[:locations].first[:latLng]

    OpenStruct.new({
      latitude: geocoords[:lat],
      longitude: geocoords[:lng]
    })
  end
end
