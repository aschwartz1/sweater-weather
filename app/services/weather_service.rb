class WeatherService
  def self.fetch_forecast(latitude, longitude, num_daily: 6, num_hourly: 8)
    response = get_onecall(latitude, longitude)
    format_forecast_response(response, num_daily, num_hourly)
  end

  def self.fetch_hourly(latitude, longitude, num_results: 9)
    response = get_onecall(latitude, longitude)
    format_hourly_response(response, num_results)
  end

  def self.fetch_daily(latitude, longitude, num_results: 9)
    response = get_onecall(latitude, longitude)
    format_daily_response(response, num_results)
  end

  private_class_method

  def self.weather_connection
    @weather_connection ||= Faraday.new 'https://api.openweathermap.org/data/2.5' do |conn|
      conn.params[:appid] = ENV['openweather_key']
    end
  end

  def self.get_onecall(latitude, longitude)
    weather_connection.get('onecall') do |req|
      req.params[:lat] = latitude
      req.params[:lon] = longitude
      req.params[:units] = 'imperial'
      req.params[:exclude] = 'minutely,alerts'
    end
  end

  def self.format_forecast_response(response, num_daily, num_hourly)
    body = JSON.parse(response.body, symbolize_names: true)

    OpenStruct.new({
      id: nil,
      current_weather: parse_current_weather(body),
      daily_weather: parse_daily_weather(body, num_daily),
      hourly_weather: parse_hourly_weather(body, num_hourly)
    })
  end

  def self.format_hourly_response(response, num_results)
    body = JSON.parse(response.body, symbolize_names: true)

    parsed = parse_hourly_weather(body, num_results)

    parsed.map do |hour_weather|
      OpenStruct.new(hour_weather)
    end
  end

  def self.format_daily_response(response, num_results)
    body = JSON.parse(response.body, symbolize_names: true)

    parsed = parse_daily_weather(body, num_results)

    parsed.map do |day_weather|
      OpenStruct.new(day_weather)
    end
  end

  # rubocop:disable Metrics/MethodLength
  def self.parse_current_weather(body)
    offset = body[:timezone_offset]
    current = body[:current]
    {
      datetime: local_time_from_unix(current[:dt], offset).to_s,
      sunrise: local_time_from_unix(current[:sunrise], offset).to_s,
      sunset: local_time_from_unix(current[:sunset], offset).to_s,
      temperature: current[:temp],
      feels_like: current[:feels_like],
      humidity: current[:humidity],
      uvi: current[:uvi],
      visibility: current[:visibility],
      conditions: current[:weather].first[:description],
      icon: current[:weather].first[:icon]
    }
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def self.parse_daily_weather(body, days)
    return [] unless days.positive? && days <= 7

    offset = body[:timezone_offset]
    daily = body[:daily]

    (0..(days - 1)).map do |i|
      {
        date: local_time_from_unix(daily[i][:dt], offset).strftime('%F'),
        sunrise: local_time_from_unix(daily[i][:sunrise], offset).to_s,
        sunset: local_time_from_unix(daily[i][:sunset], offset).to_s,
        day_temp: daily[i][:temp][:day],
        max_temp: daily[i][:temp][:max],
        min_temp: daily[i][:temp][:min],
        conditions: daily[i][:weather].first[:description],
        icon: daily[i][:weather].first[:icon]
      }
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def self.parse_hourly_weather(body, hours)
    return [] unless hours.positive? && hours <= 48

    offset = body[:timezone_offset]
    hourly = body[:hourly]

    (0..(hours - 1)).map do |i|
      {
        time: local_time_from_unix(hourly[i][:dt], offset).strftime('%T'),
        temperature: hourly[i][:temp],
        conditions: hourly[i][:weather].first[:description],
        icon: hourly[i][:weather].first[:icon]
      }
    end
  end
  # rubocop:enable Metrics/MethodLength

  def self.local_time_from_unix(timestamp, offset)
    Time.find_zone(offset).at(timestamp)
  end
end
