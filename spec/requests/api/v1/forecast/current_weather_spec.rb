require 'rails_helper'

RSpec.describe 'Forecast' do
  describe 'Current Weather' do
    it 'is correct' do
      VCR.use_cassette('denver_weather_request') do
        get api_v1_forecast_path(location: 'denver,co')

        expect(response).to be_successful
        body = JSON.parse(response.body, symbolize_names: true)
        current_weather = body[:data][:attributes][:current_weather]

        expect(current_weather.keys).to eq(current_weather_keys)
        expect(current_weather[:datetime]).to eq('2021-04-24 13:03:29 -0600')
        expect(current_weather[:sunrise]).to eq('2021-04-24 06:08:57 -0600')
        expect(current_weather[:sunset]).to eq('2021-04-24 19:46:43 -0600')
        expect(current_weather[:temperature]).to eq(58.66)
        expect(current_weather[:feels_like]).to eq(56.19)
        expect(current_weather[:humidity]).to eq(42)
        expect(current_weather[:uvi]).to eq(6.35)
        expect(current_weather[:visibility]).to eq(10000)
        expect(current_weather[:conditions]).to eq('overcast clouds')
        expect(current_weather[:icon]).to eq('04d')
      end
    end
  end

  def current_weather_keys
    %i{ datetime
          sunrise
          sunset
          temperature
          feels_like
          humidity
          uvi
          visibility
          conditions
          icon
    }
  end
end

