require_relative '../../app/services/weather_service.rb'

require 'rails_helper'

RSpec.describe 'Forecast Service' do
  let(:geocoords) { OpenStruct.new({latitude: 39.738453, longitude: -104.984853}) }

  describe 'General Structure' do
    it 'has an id' do
      VCR.use_cassette('denver_weather_request') do
        result = WeatherService.fetch_weather_data(geocoords)
        expect(result.id).to be_nil
      end
    end
  end

  describe 'Hourly Weather' do
    it 'is correct' do
      VCR.use_cassette('denver_weather_request') do
        result = WeatherService.fetch_weather_data(geocoords)

        hourly_weather = result.hourly_weather

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

  describe 'Daily Weather' do
    it 'is correct' do
      VCR.use_cassette('denver_weather_request') do
        result = WeatherService.fetch_weather_data(geocoords)

        daily_weather = result.daily_weather

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

  describe 'Current Weather' do
    it 'is correct' do
      VCR.use_cassette('denver_weather_request') do
        result = WeatherService.fetch_weather_data(geocoords)

        current_weather = result.current_weather

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
  def hourly_weather_keys
    %i{time temperature conditions icon}
  end
end

