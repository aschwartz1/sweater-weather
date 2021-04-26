class Api::V1::SalariesController < ApplicationController
  def show
    destination = params[:destination]
    geocords = fetch_geocoords(destination)
    weather_data = fetch_weather_data(geocords)
    salary_data = fetch_salary_data(destination)
    combined = combine_data(destination, weather_data, salary_data)

    render json: SalariesSerializer.new(combined)
  end

  private

  def combine_data(location, weather, salaries)
    OpenStruct.new({
      id: nil,
      destination: location,
      forecast: weather.to_h,
      salaries: salaries
    })
  end

  # BEGIN SalaryService
  def fetch_salary_data(destination)
    response = salary_connection.get("urban_areas/slug:#{destination}/salaries")
    format_salary_response(response)
  end

  def format_salary_response(response)
    body = JSON.parse(response.body, symbolize_names: true)
    salaries = body[:salaries]

    format_salaries(sorted_job_titles, salaries)
  end

  def format_salaries(pluck_titles, salaries)
    salaries.map do |salary|
      {
        title: salary[:job][:title],
        min: format_salary(salary[:salary_percentiles][:percentile_25]),
        max: format_salary(salary[:salary_percentiles][:percentile_75])
      } if pluck_titles.include? salary[:job][:title]
    end.compact
  end

  def salary_connection
    @salary_connection ||= Faraday.new 'https://api.teleport.org/api'
  end

  def format_salary(salary)
    ActiveSupport::NumberHelper.number_to_currency(salary)
  end

  def sorted_job_titles
    [
      'Data Analyst',
      'Data Scientist',
      'Mobile Developer',
      'QA Engineer',
      'Software Engineer',
      'Systems Administrator',
      'Web Developer'
    ]
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

    OpenStruct.new(parse_forecast(body))
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
