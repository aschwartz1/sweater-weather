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

  def parse_current_weather(body)
    current = body[:current]
    require "pry"; binding.pry
    {
      datetime: beautify_datetime(current[:dt]),
      sunrise: beautify_datetime(current[:sunrise]),
      sunset: beautify_datetime(current[:sunset]),
      temperature: current[:temp],
      feels_like: current[:feels_like],
      humidity: current[:humidity],
      uvi: current[:uvi],
      visibility: current[:visibility],
      conditions: current[:weather].first[:description],
      icon: current[:weather].first[:icon]
    }
  end

  def parse_daily_weather(body, days)
    []
  end

  def parse_hourly_weather(body, hours)
    []
  end

  def beautify_datetime(datetime)
    datetime = 'TODO'
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
