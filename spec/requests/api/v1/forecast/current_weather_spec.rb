require 'rails_helper'

RSpec.describe 'Forecast' do
  describe 'Current Weather' do
    it 'is correct' do
      # TODO: make this look straight to current weather and do the expectations
      get api_v1_forecast_path(location: 'denver,co')

      expect(response).to be_successful
      body = JSON.parse(response.body, symbolize_names: true)
      current_weather = body[:data][:attributes][:current_weather]

      expect(current_weather.keys).to eq(current_weather_keys)
      expect(current_weather[:datetime]).to eq('2020-09-30 13:27:03 -0600')
      expect(current_weather[:sunrise]).to eq('2020-09-30 06:27:03 -0600')
      expect(current_weather[:sunset]).to eq('2020-09-30 18:27:03 -0600')
      expect(current_weather[:temperature]).to eq(45.43)
      expect(current_weather[:feels_like]).to eq(40.01)
      expect(current_weather[:humidity]).to eq(20.1)
      expect(current_weather[:uvi]).to eq(5.37)
      expect(current_weather[:visibility]).to eq(10000)
      expect(current_weather[:conditions]).to eq('broken clouds')
      expect(current_weather[:icon]).to eq('04d')
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

