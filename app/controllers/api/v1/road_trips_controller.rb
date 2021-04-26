class Api::V1::RoadTripsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :validate_params_exist

  def create
    if User.valid_api_key?(road_trip_params[:api_key])
      trip = fetch_road_trip(road_trip_params[:origin], road_trip_params[:destination])
      render json: RoadTripSerializer.new(trip)
    else
      render json: errors_serializer(['Invalid api key']), status: :unauthorized
    end
  end

  private

  def fetch_road_trip(origin, destination)
    format_road_trip('placeholder')
  end

  def format_road_trip(args)
    weather_data = {temperature: 60.1, conditions: 'conditions'}

    OpenStruct.new({
      id: nil,
      start_city: 'start',
      end_city: 'end',
      travel_time: 'travel time',
      weather_at_eta: weather_data
    })
  end

  def road_trip_params
    @road_trip_params ||= parse_params
  end

  def parse_params
    return {} if request.body.read.blank?

    JSON.parse(request.body.read, symbolize_names: true)
  end

  def validate_params_exist
    render json: errors_serializer(['No params found in request body']), status: :bad_request unless all_params_exist?
  end

  def all_params_exist?
    expected = %i[origin destination api_key]

    expected.all? do |param|
      road_trip_params.include?(param)
    end
  end

  def errors_serializer(messages)
    ErrorsSerializer.new(ostructify_errors(messages))
  end

  def ostructify_errors(error_messages)
    error_messages.map do |message|
      OpenStruct.new({
        id: nil,
        message: message
      })
    end
  end
end
