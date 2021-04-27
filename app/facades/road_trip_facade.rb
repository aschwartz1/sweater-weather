require_relative '../services/map_service'
require_relative '../services/weather_service'

class RoadTripFacade
  def self.create_trip(origin, destination)
    directions = fetch_directions(origin, destination)
    eta_weather = fetch_eta_weather(directions.to[:latitude], directions.to[:longitude], directions.travel_time)

    format_response(directions, eta_weather)
  end

  private_class_method

  def self.format_response(directions, eta_weather)
    OpenStruct.new({
      id: nil,
      start_city: directions.from[:name],
      end_city: directions.to[:name],
      travel_time: format_travel_time(directions.travel_time),
      weather_at_eta: eta_weather
    })
  end

  def self.fetch_directions(origin, destination)
    MapService.fetch_directions(from: origin, to: destination)
  end

  def self.fetch_eta_weather(lat, lng, travel_time)
    hours = travel_time.split(':').first.to_i
    scope = days_or_hours(hours)
    results_needed = (hours % 48) + 1

    data = fetch_weather_for_scope(lat, lng, scope, results_needed)
    eta_weather = data.last

    trim_eta_weather(eta_weather)
  end

  def self.trim_eta_weather(data)
    {
      temperature: data.temperature || average(data.max_temp, data.min_temp),
      conditions: data.conditions
    }
  end

  def self.average(num1, num2)
    (num1 = num2) / 2.0
  end

  def self.fetch_weather_for_scope(lat, lng, scope, results_needed)
    return WeatherService.fetch_hourly(lat, lng, num_results: results_needed) if scope == :hours

    WeatherService.fetch_daily(lat, lng, num_results: results_needed)
  end

  def self.days_or_hours(hours)
    return :hours if hours < 48
    :days
  end

  def self.format_travel_time(time)
    # Comes in as <HH:MM:SS> and we want to format to 'X hours, Y minutes'
    hms = time.split(':')
    "#{hms[0].to_i} hours, #{hms[1].to_i} minutes"
  end
end
