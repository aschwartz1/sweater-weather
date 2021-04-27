require_relative '../../../services/map_service.rb'

class Api::V1::RoadTripsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :validate_params_exist

  def create
    if User.valid_api_key?(request_params[:api_key])
      directions = MapService.fetch_directions(from: request_params[:origin], to: request_params[:destination])
      # TODO: get start lat & long, end lat & long, trip dur'n and send to fetch_weather method
      weather = fetch_destination_weather(directions.to[:latitude], directions.to[:longitude], directions.travel_time)
      render json: RoadTripSerializer.new(create_trip(directions, weather))
    else
      render json: errors_serializer(['Invalid api key']), status: :unauthorized
    end
  end

  private

  # BEGIN RoadTripsFacade
  def create_trip(directions, weather)
    OpenStruct.new({
      id: nil,
      start_city: directions.from[:name],
      end_city: directions.to[:name],
      travel_time: format_travel_time(directions.travel_time),
      weather_at_eta: weather
    })
  end

  def format_travel_time(time)
    # hour minute second
    hms = time.split(':')
    "#{hms[0].to_i} hour(s), #{hms[1].to_i} minutes"
  end

  def fetch_destination_weather(lat, lng, travel_time)
    {
      temperature: 0,
      conditions: 'not yet implemented'
    }
  end
  # END RoadTripsFacade

  def request_params
    @request_params ||= parse_params
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
      request_params.include?(param)
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
