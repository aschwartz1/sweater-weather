require_relative '../../../services/map_service'
require_relative '../../../services/weather_service'

class Api::V1::ForecastsController < ApplicationController
  before_action :validate_params

  def show
    geocoords = MapService.fetch_geocoords(params[:location])

    weather_data = WeatherService.fetch_forecast(geocoords.latitude, geocoords.longitude)

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
end
