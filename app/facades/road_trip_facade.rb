require_relative '../services/map_service'

class RoadTripFacade
  def self.create_trip(origin, destination)
    directions = fetch_directions(origin, destination)
    weather = fetch_destination_weather(directions.to[:latitude], directions.to[:longitude], directions.travel_time)

    format_response(directions, weather)
  end

  private_class_method

  def self.format_response(directions, weather)
    OpenStruct.new({
      id: nil,
      start_city: directions.from[:name],
      end_city: directions.to[:name],
      travel_time: format_travel_time(directions.travel_time),
      weather_at_eta: weather
    })
  end

  def self.fetch_directions(origin, destination)
    MapService.fetch_directions(from: origin, to: destination)
  end

  def self.fetch_destination_weather(lat, lng, travel_time)
    {
      temperature: lat + lng,
      conditions: "not yet implemented #{travel_time}"
    }
  end

  def self.format_travel_time(time)
    # Comes in as <HH:MM:SS> and we want to format to 'X hours, Y minutes'
    hms = time.split(':')
    "#{hms[0].to_i} hours, #{hms[1].to_i} minutes"
  end
end
