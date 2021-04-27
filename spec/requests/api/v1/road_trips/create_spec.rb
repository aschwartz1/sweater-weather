require 'rails_helper'

RSpec.describe 'Road Trips Create', type: :request do
  before :each do
    @user = create(:user, :test)
    @headers = {'Content-Type' => 'application/json'}
  end

  describe 'Happy Path' do
    before :each do
      @body = {
        'origin': 'Denver,CO',
        'destination': 'Pueblo,CO',
        'api_key': @user.api_key,
      }
    end

    it 'returns correct structure' do
      post api_v1_road_trip_path, headers: @headers, params: @body, as: :json

      expect(response).to be_successful
      body = JSON.parse(response.body, symbolize_names: true)

      expect(body.keys).to eq([:data])
      data = body[:data]

      expect(data.keys).to eq([:id, :type, :attributes])
      expect(data[:id]).to be_nil
      expect(data[:type]).to eq('roadtrip')
      expect(data[:attributes].keys).to eq([:start_city, :end_city, :travel_time, :weather_at_eta])
      attributes = data[:attributes]

      expect(attributes[:start_city]).to be_a(String)
      expect(attributes[:end_city]).to be_a(String)
      expect(attributes[:travel_time]).to be_a(String)
      expect(attributes[:weather_at_eta].keys).to eq([:temperature, :conditions])
      weather = attributes[:weather_at_eta]

      expect(weather[:temperature]).to be_a(Float).or be_an(Integer)
      expect(weather[:conditions]).to be_a(String)
    end

    it 'returns start & end cities and travel time' do
      post api_v1_road_trip_path, headers: @headers, params: @body, as: :json

      expect(response).to be_successful
      body = JSON.parse(response.body, symbolize_names: true)
      data = body[:data]
      attributes = data[:attributes]

      expect(attributes[:start_city]).to eq('Denver, CO')
      expect(attributes[:end_city]).to eq('Pueblo, CO')
      expect(attributes[:travel_time]).to eq('1 hour(s), 44 minutes')
    end
  end

  describe 'sad path' do
    it 'returns unauthenticated error if api_key is invalid' do
      body = {
        'origin': 'Denver,CO',
        'destination': 'Pueblo,CO',
        'api_key': 'invalid',
      }

      post api_v1_road_trip_path, headers: @headers, params: body, as: :json

      expect(response).to have_http_status(401)
      body = JSON.parse(response.body, symbolize_names: true)

      data = body[:data]
      expect(data).to be_an(Array)
      expect(data.size).to eq(1)

      first = data.first
      expect(first.keys).to eq([:id, :type, :attributes])

      attributes = first[:attributes]
      expect(attributes.keys).to eq([:message])
      expect(attributes[:message]).to eq("Invalid api key")
    end

    it 'returns error if required body params are not sent' do
      post api_v1_road_trip_path, headers: @headers, as: :json
      expect(response).to have_http_status(400)
    end

    xit 'returns error with message if route is impossible' do
    end
  end
end
