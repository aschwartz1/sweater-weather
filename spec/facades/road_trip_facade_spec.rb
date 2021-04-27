require_relative '../../app/facades/road_trip_facade'
require 'rails_helper'

RSpec.describe 'Road Trip Facade' do
  describe 'happy path' do
    it 'creates a trip with the expected structure (hourly weather)' do
      VCR.use_cassette('portland_to_dallas') do
        trip = RoadTripFacade.create_trip('portland,or', 'dallas,tx')

        expect(trip).to be_an(OpenStruct)
        expect(trip).to respond_to(:id)
        expect(trip).to respond_to(:start_city)
        expect(trip).to respond_to(:end_city)
        expect(trip).to respond_to(:travel_time)
        expect(trip).to respond_to(:weather_at_eta)

        expect(trip.start_city).to be_a(String)
        expect(trip.end_city).to be_a(String)
        expect(trip.travel_time).to be_a(String)
        expect(trip.weather_at_eta).to be_a(Hash)

        expect(trip.travel_time).to match(/\A\d{1,2} hours, \d{1,2} minutes\z/)

        weather = trip.weather_at_eta
        expect(weather.keys).to eq([:temperature, :conditions])
        expect(weather[:temperature]).to be_a(Numeric)
        expect(weather[:conditions]).to be_a(String)
      end
    end
  end

  it 'creates a trip with the expected structure (daily weather)' do
      VCR.use_cassette('san_francisco_to_caribou') do
        trip = RoadTripFacade.create_trip('san francisco,ca', 'caribou,me')

        expect(trip).to be_an(OpenStruct)
        expect(trip).to respond_to(:id)
        expect(trip).to respond_to(:start_city)
        expect(trip).to respond_to(:end_city)
        expect(trip).to respond_to(:travel_time)
        expect(trip).to respond_to(:weather_at_eta)

        expect(trip.start_city).to be_a(String)
        expect(trip.end_city).to be_a(String)
        expect(trip.travel_time).to be_a(String)
        expect(trip.weather_at_eta).to be_a(Hash)

        expect(trip.travel_time).to match(/\A\d{1,2} hours, \d{1,2} minutes\z/)

        weather = trip.weather_at_eta
        expect(weather.keys).to eq([:temperature, :conditions])
        expect(weather[:temperature]).to be_a(Numeric)
        expect(weather[:conditions]).to be_a(String)
      end
  end
end
