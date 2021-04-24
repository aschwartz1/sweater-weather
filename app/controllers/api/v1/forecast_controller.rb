class Api::V1::ForecastController < ApplicationController
  before_action :validate_params

  def show
    f = fetch_current_weather(params[:location])
    # TODO: make a serializer for the current weather
  end

  def fetch_current_weather(location)
    geocoords = fetch_geocoords(location)
  end

  private

  def validate_params
    render json: '', status: :bad_request if params[:location].blank?
  end

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

  # BEGIN WeatherService

  # END WeatherService
end
