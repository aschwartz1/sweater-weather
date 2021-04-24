require 'rails_helper'

RSpec.describe 'Forecast' do
  describe 'Hourly Weather' do
    it 'is correct' do
      VCR.use_cassette('denver_weather_request') do
        get api_v1_forecast_path(location: 'denver,co')

        expect(response).to be_successful
        body = JSON.parse(response.body, symbolize_names: true)
        hourly_weather = body[:data][:attributes][:hourly_weather]

        expect(hourly_weather).to be_an(Array)
        expect(hourly_weather.size).to eq(8)

        first = hourly_weather.first
        expect(first.keys).to eq(hourly_weather_keys)
        expect(first[:time]).to eq('14:00:00')
        expect(first[:temperature]).to eq(59.74)
        expect(first[:conditions]).to eq('overcast clouds')
        expect(first[:icon]).to eq('04d')

        last = hourly_weather.last
        expect(last.keys).to eq(hourly_weather_keys)
        expect(last[:time]).to eq('21:00:00')
        expect(last[:temperature]).to eq(57.18)
        expect(last[:conditions]).to eq('overcast clouds')
        expect(last[:icon]).to eq('04n')
      end
    end
  end

  def hourly_weather_keys
    %i{time temperature conditions icon}
  end
end

