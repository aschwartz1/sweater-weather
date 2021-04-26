class Api::V1::SalariesController < ApplicationController
  def show
    geocords = fetch_geocoords(params[:destination])
    weather_data = fetch_weather_data(geocords)
    salary_data = fetch_salary_data(params[:destination])
  end

  private

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

  # BEGIN WeatherService
  def weather_connection
    @weather_connection ||= Faraday.new 'https://api.openweathermap.org/data/2.5' do |conn|
      conn.params[:appid] = ENV['openweather_key']
    end
  end

  def fetch_weather_data(geocoords)
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
      forecast: parse_forecast(body),
    })
  end

  def parse_forecast(body)
    current = body[:current]
    {
      summary: current[:weather].first[:description],
      temperature: display_temp(current[:temp])
    }
  end

  def display_temp(temperature)
    "#{temperature.to_i} F"
  end
  # END WeatherService
end
