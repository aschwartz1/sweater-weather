class MapService
  def self.fetch_geocoords(location)
    response = map_connection.get('geocoding/v1/address') do |req|
      req.params[:location] = location
    end

    format_map_response(response)
  end

  def self.fetch_directions(from:, to:)
    response = map_connection.get('directions/v2/route') do |req|
      req.params[:from] = from
      req.params[:to] = to
    end

    format_directions(response)
  end

  private_class_method

  def self.map_connection
    @map_connection ||= Faraday.new 'http://www.mapquestapi.com' do |conn|
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

  def self.format_directions(response)
    body = JSON.parse(response.body, symbolize_names: true)
    route = body[:route]
    locations = route[:locations]

    OpenStruct.new({
      from: extract_location_info(locations[0]),
      to: extract_location_info(locations[1]),
      travel_time: route[:formattedTime]
    })
  end

  def self.extract_location_info(location)
    {
      name: "#{location[:adminArea5]}, #{location[:adminArea3]}",
      latitude: location[:latLng][:lat],
      longitude: location[:latLng][:lng]
    }
  end
end
