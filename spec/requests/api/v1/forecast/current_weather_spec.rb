require 'rails_helper'

RSpec.describe 'Forecast Current Weather' do
  describe 'response' do
    it 'works' do
      get api_v1_forecast_path(location: 'denver,co')

      expect(response).to be_successful
      body = JSON.parse(response.body, symbolize_names: true)

      expect(body.length).to eq(1)
      expect(body[:data]).to be_a(Hash)
      expect(body[:data].length).to eq(1)

      data = body[:data]
      expect(data.keys).to eq([:id, :type, :attributes])
      expect(data[:id]).to eq(nil)
      expect(data[:type]).to eq('geocoordinates')
      expect(data[:attributes]).to be_a(Hash)

      attributes = data[:attributes]
      expect(attributes.keys).to eq([:latitude, :longitude])
      expect(attributes[:latitude]).to eq('39.738453')
      expect(attributes[:longitude]).to eq('-104.984853')
    end
  end

  describe 'sad path' do
    it 'returns error if query params are not sent' do
      get api_v1_forecast_path
      expect(response).to have_http_status(400)
    end

    xit 'returns error if location param is not the right format' do
      get api_v1_forecast_path(location: 'denver,colorado')
      expect(response).to have_http_status(400)
    end
  end

  # describe 'instance method' do
  #   describe '#fetch_geocoords' do
  #     it 'works' do
  #       # TODO: make the call w/ 'denver,co' as location
  #       expect(result).to be_an(OpenStruct)
  #       expect(result.latitude).to eq(39.738453)
  #       expect(results.longitude).to eq(-104.984853)
  #     end
  #   end
  # end
end

