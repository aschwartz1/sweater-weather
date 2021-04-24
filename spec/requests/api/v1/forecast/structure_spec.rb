require 'rails_helper'

RSpec.describe 'Forecast' do
  describe 'General Structure' do
    it 'is correct' do
      VCR.use_cassette('denver_weather_request') do
        get api_v1_forecast_path(location: 'denver,co')

        expect(response).to be_successful
        body = JSON.parse(response.body, symbolize_names: true)

        expect(body.length).to eq(1)
        expect(body[:data]).to be_a(Hash)
        expect(body[:data].length).to eq(3)

        data = body[:data]
        expect(data.keys).to eq([:id, :type, :attributes])
        expect(data[:id]).to eq(nil)
        expect(data[:type]).to eq('forecast')
        expect(data[:attributes]).to be_a(Hash)
        expect(data[:attributes].keys).to eq([:current_weather, :daily_weather, :hourly_weather])
      end
    end
  end

  describe 'sad path' do
    it 'returns error if query params are not sent' do
      get api_v1_forecast_path
      expect(response).to have_http_status(400)
    end

    it 'returns error if location param is not the right format' do
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

