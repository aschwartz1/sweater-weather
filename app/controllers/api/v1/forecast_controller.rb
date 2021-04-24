class Api::V1::ForecastController < ApplicationController
  before_action :validate_params

  def show
    # fetch_current_weather(params[:location])

    complete_response = OpenStruct.new({
      id: nil,
      current_weather: {},
      daily_weather: [],
      hourly_weather: []
    })

    render json: ForecastSerializer.new(complete_response)
  end

  def fetch_current_weather(location)
    geocoords = fetch_geocoords(location)
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
    # result = body[:results].first
    geocoords = body[:results].first[:locations].first[:latLng]

    OpenStruct.new({
      latitude: geocoords[:lat],
      longitude: geocoords[:lng]
    })
  end
  # END MapService
end
