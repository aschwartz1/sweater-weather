class Api::V1::RoadTripsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :validate_params_exist

  def create
    if User.valid_api_key?(road_trip_params[:api_key])
      directions = fetch_directions(road_trip_params[:origin], road_trip_params[:destination])
      # TODO: get start lat & long, end lat & long, trip dur'n and send to fetch_weather method
      weather = fetch_destination_weather(directions[:end_city][:lat], directions[:end_city][:lng], directions[:travel_time])
      render json: RoadTripSerializer.new(create_trip(directions, weather))
    else
      render json: errors_serializer(['Invalid api key']), status: :unauthorized
    end
  end

  private

  def create_trip(directions, weather)
    OpenStruct.new({
      id: nil,
      start_city: directions[:start_city][:name],
      end_city: directions[:end_city][:name],
      travel_time: format_travel_time(directions[:travel_time]),
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

  def fetch_directions(origin, destination)
    response = directions_connection.get('route') do |req|
      req.params[:from] = origin
      req.params[:to] = destination
    end

    format_directions(response)
  end

  def format_directions(response)
    body = JSON.parse(response.body, symbolize_names: true)
    route = body[:route]
    locations = route[:locations]

    {
      start_city: {
        name: "#{locations[0][:adminArea5]}, #{route[:locations][0][:adminArea3]}",
        lat: locations[0][:latLng][:lat],
        lng: locations[0][:latLng][:lng]
      },
      end_city: {
        name: "#{locations[1][:adminArea5]}, #{route[:locations][1][:adminArea3]}",
        lat: locations[1][:latLng][:lat],
        lng: locations[1][:latLng][:lng]
      },
      travel_time: route[:formattedTime]
    }
  end

  def directions_connection
    @directions_connection ||= Faraday.new('http://www.mapquestapi.com/directions/v2') do |conn|
      conn.params[:key] = ENV['mapquest_key']
    end
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
