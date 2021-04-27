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

  private

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
      from: {
        name: "#{locations[0][:adminArea5]}, #{route[:locations][0][:adminArea3]}",
        latitude: locations[0][:latLng][:lat],
        longitude: locations[0][:latLng][:lng]
      },
      to: {
        name: "#{locations[1][:adminArea5]}, #{route[:locations][1][:adminArea3]}",
        latitude: locations[1][:latLng][:lat],
        longitude: locations[1][:latLng][:lng]
      },
      travel_time: route[:formattedTime]
    })
  end
end
