# Adding temporarily because vim-test is causing controller to not have scope of ~/app/ for some reason?
require_relative '../../../services/weather_service.rb'

class Api::V1::ForecastsController < ApplicationController
  before_action :validate_params

  def show
    geocords = fetch_geocoords(params[:location])

    weather_data = WeatherService.fetch_weather_data(geocords)

    render json: ForecastSerializer.new(weather_data)
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

  # BEGIN WeatherFacade
  # END WeatherFacade

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
