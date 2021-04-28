require 'rails_helper'

RSpec.describe 'Forecast Service' do
  describe 'Geocoords for city' do
    describe 'happy path' do
      it 'returns correct structure and data' do
        VCR.use_cassette('denver_geocoords') do
          geocoords = MapService.fetch_geocoords('denver,co')

          expect(geocoords).to be_an(OpenStruct)
          expect(geocoords).to respond_to(:latitude)
          expect(geocoords).to respond_to(:longitude)

          expect(geocoords[:latitude]).to be_between(39, 40)
          expect(geocoords[:longitude]).to be_between(-105, -104)
        end
      end
    end
  end

  describe 'Directions' do
    describe 'happy path' do
      it 'returns correct structure and data' do
        VCR.use_cassette('portland_to_miami') do
          directions = MapService.fetch_directions(from: 'portland,or', to: 'miami,fl')

          expect(directions).to be_an(OpenStruct)
          expect(directions).to respond_to(:from)
          expect(directions).to respond_to(:to)
          expect(directions).to respond_to(:travel_time)

          expect(directions.from).to be_a(Hash)
          expect(directions.from.keys).to eq([:name, :latitude, :longitude])
          expect(directions.from[:name]).to eq('Portland, OR')
          expect(directions.from[:latitude]).to be_between(45, 46)
          expect(directions.from[:longitude]).to be_between(-123, -122)

          expect(directions.to).to be_a(Hash)
          expect(directions.to.keys).to eq([:name, :latitude, :longitude])
          expect(directions.to[:name]).to eq('Miami, FL')
          expect(directions.to[:latitude]).to be_between(25, 26)
          expect(directions.to[:longitude]).to be_between(-81, -80)

          expect(directions.travel_time).to be_a(String)
          # Expecting the format HH:MM:SS
          expect(directions.travel_time.split(':').size).to eq(3)
        end
      end
    end

    describe 'sad path' do
      it 'returns some sort of error if route is impossible' do
        VCR.use_cassette('impossible_route') do
          directions = MapService.fetch_directions(from: 'dallas,tx', to: 'london,uk')

          expect(directions).to be_nil
        end
      end
    end
  end
end
