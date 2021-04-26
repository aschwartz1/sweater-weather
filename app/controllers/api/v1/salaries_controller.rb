class Api::V1::SalariesController < ApplicationController
  def show
    destination = params[:destination]
    geocords = fetch_geocoords(destination)
    weather_data = fetch_weather_data(geocords)
    salary_data = fetch_salary_data(destination)

    combined = combine_data(destination, weather_data, salary_data)
  end

  private

  def combine_data(location, weather, salaries)
    OpenStruct.new({
      destination: location,
      forecast: weather.to_h,
      salaries: salaries
    })
  end

  # BEGIN SalaryService
  def fetch_salary_data(destination)
    # response = salary_connection.get("urban_areas/slug:#{location}/salaries")
    format_salary_response('placeholder')
  end

  def format_salary_response(response)
    # body = JSON.parse(response.body, symbolize_names: true)
    # salaries = body[:salaries]
    extract_salaries('salaries')
  end

  def extract_salaries(placeholder)
    7.times.map do
      {
        title: 'title',
        min: 'min',
        max: 'max'
      }
    end
  end

  def salary_connection
    @salary_connection ||= Faraday.new 'https://api.teleport.org/api'
  end
  # END SalaryService

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
