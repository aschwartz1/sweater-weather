class Api::V1::ForecastController < ApplicationController
  before_action :validate_params

  def show
    geocords = fetch_geocoords(params[:location])

    current_weather = fetch_current_weather(geocords)
    current_weather[:id] = nil

    complete_response = OpenStruct.new(current_weather)

    render json: ForecastSerializer.new(complete_response)
  end

  private

  def validate_params
    # Desired format like `denver,co`
    render json: '', status: :bad_request and return if params[:location].blank?

    split = params[:location].split(',')
    # Location exists but is not in correct `city,state` format
    render json: '', status: :bad_request and return unless split.size == 2
    # Location seemed to be right format, but state was not a state code of 2 letters
    render json: '', status: :bad_request and return unless split.last.size == 2
  end

  # BEGIN WeatherService
  def weather_connection
    @weather_connection ||= Faraday.new 'https://api.openweathermap.org/data/2.5' do |conn|
      conn.params[:appid] = ENV['openweather_key']
    end
  end

  def fetch_current_weather(geocoords)
    response = weather_connection.get('onecall') do |req|
      req.params[:lat] = geocoords.latitude
      req.params[:lon] = geocoords.longitude
      req.params[:units] = 'imperial'
      req.params[:exclude] = 'minutely,alerts'
    end

    format_weather_response(response)
  end

  def format_weather_response(response)
    body = JSON.parse(response.body, symbolize_names: true)

    OpenStruct.new({
      current_weather: parse_current_weather(body),
      daily_weather: parse_daily_weather(body, 5),
      hourly_weather: parse_hourly_weather(body, 8)
    })
  end

  # rubocop:disable Metrics/MethodLength
  def parse_current_weather(body)
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
  def parse_daily_weather(body, days)
    return [] unless days.positive?

    offset = body[:timezone_offset]
    daily = body[:daily]

    (1..days).map do |i|
      {
        date: local_time_from_unix(daily[i][:dt], offset).strftime('%F'),
        sunrise: local_time_from_unix(daily[i][:sunrise], offset).to_s,
        sunset: local_time_from_unix(daily[i][:sunset], offset).to_s,
        max_temp: daily[i][:temp][:max],
        min_temp: daily[i][:temp][:min],
        conditions: daily[i][:weather].first[:description],
        icon: daily[i][:weather].first[:icon]
      }
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def parse_hourly_weather(body, hours)
    return [] unless hours.positive?

    offset = body[:timezone_offset]
    hourly = body[:hourly]

    (1..hours).map do |i|
      {
        time: local_time_from_unix(hourly[i][:dt], offset).strftime('%T'),
        temperature: hourly[i][:temp],
        conditions: hourly[i][:weather].first[:description],
        icon: hourly[i][:weather].first[:icon]
      }
    end
  end
  # rubocop:enable Metrics/MethodLength

  def local_time_from_unix(timestamp, offset)
    Time.find_zone(offset).at(timestamp)
  end
  # END WeatherService

  # BEGIN MapService
  def map_connection
    @map_connection ||= Faraday.new 'http://www.mapquestapi.com/geocoding/v1' do |conn|
      conn.params[:key] = ENV['mapquest_key']
    end
  end

  def fetch_geocoords(location)
    response = map_connection.get('address') do |req|
      req.params[:location] = location
    end

    format_map_response(response)
  end

  def format_map_response(response)
    body = JSON.parse(response.body, symbolize_names: true)
    geocoords = body[:results].first[:locations].first[:latLng]

    OpenStruct.new({
      latitude: geocoords[:lat],
      longitude: geocoords[:lng]
    })
  end
  # END MapService
end
