require 'rails_helper'

RSpec.describe 'Forecast' do
  describe 'Daily Weather' do
    it 'is correct' do
      VCR.use_cassette('denver_weather_request') do
        get api_v1_forecast_path(location: 'denver,co')

        expect(response).to be_successful
        body = JSON.parse(response.body, symbolize_names: true)
        daily_weather = body[:data][:attributes][:daily_weather]

        expect(daily_weather).to be_an(Array)
        expect(daily_weather.size).to eq(5)

        first = daily_weather.first
        expect(first.keys).to eq(daily_weather_keys)
        expect(first[:date]).to eq('2021-04-25')
        expect(first[:sunrise]).to eq('2021-04-25 06:07:37 -0600')
        expect(first[:sunset]).to eq('2021-04-25 19:47:44 -0600')
        expect(first[:max_temp]).to eq(75.81)
        expect(first[:min_temp]).to eq(47.14)
        expect(first[:conditions]).to eq('scattered clouds')
        expect(first[:icon]).to eq('03d')

        last = daily_weather.last
        expect(last.keys).to eq(daily_weather_keys)
        expect(last[:date]).to eq('2021-04-29')
        expect(last[:sunrise]).to eq('2021-04-29 06:02:27 -0600')
        expect(last[:sunset]).to eq('2021-04-29 19:51:48 -0600')
        expect(last[:max_temp]).to eq(65.14)
        expect(last[:min_temp]).to eq(44.15)
        expect(last[:conditions]).to eq('light rain')
        expect(last[:icon]).to eq('10d')
      end
    end
  end

  def daily_weather_keys
    %i{ date
          sunrise
          sunset
          max_temp
          min_temp
          conditions
          icon
    }
  end
end

