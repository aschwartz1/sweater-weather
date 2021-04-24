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

