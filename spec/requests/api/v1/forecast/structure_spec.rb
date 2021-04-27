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

  describe 'Current Weather' do
    it 'is correct' do
      VCR.use_cassette('denver_weather_request') do
        get api_v1_forecast_path(location: 'denver,co')

        expect(response).to be_successful
        body = JSON.parse(response.body, symbolize_names: true)
        current_weather = body[:data][:attributes][:current_weather]

        expect(current_weather.keys).to eq(current_weather_keys)
        expect(current_weather[:datetime]).to be_a(String)
        expect(current_weather[:sunrise]).to be_a(String)
        expect(current_weather[:sunset]).to be_a(String)
        expect(current_weather[:temperature]).to be_a(Numeric)
        expect(current_weather[:feels_like]).to be_a(Numeric)
        expect(current_weather[:humidity]).to be_a(Numeric)
        expect(current_weather[:uvi]).to be_a(Numeric)
        expect(current_weather[:visibility]).to be_an(Integer)
        expect(current_weather[:conditions]).to be_a(String)
        expect(current_weather[:icon]).to be_a(String)
      end
    end
  end

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
        expect(first[:date]).to be_a(String)
        expect(first[:sunrise]).to be_a(String)
        expect(first[:sunset]).to be_a(String)
        expect(first[:max_temp]).to be_a(Numeric)
        expect(first[:min_temp]).to be_a(Numeric)
        expect(first[:conditions]).to be_a(String)
        expect(first[:icon]).to be_a(String)

        last = daily_weather.last
        expect(last.keys).to eq(daily_weather_keys)
        expect(last[:date]).to be_a(String)
        expect(last[:sunrise]).to be_a(String)
        expect(last[:sunset]).to be_a(String)
        expect(last[:max_temp]).to be_a(Numeric)
        expect(last[:min_temp]).to be_a(Numeric)
        expect(last[:conditions]).to be_a(String)
        expect(last[:icon]).to be_a(String)
      end
    end
  end

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
        expect(first[:time]).to be_a(String)
        expect(first[:temperature]).to be_a(Numeric)
        expect(first[:conditions]).to be_a(String)
        expect(first[:icon]).to be_a(String)

        last = hourly_weather.last
        expect(last.keys).to eq(hourly_weather_keys)
        expect(last[:time]).to be_a(String)
        expect(last[:temperature]).to be_a(Numeric)
        expect(last[:conditions]).to be_a(String)
        expect(last[:icon]).to be_a(String)
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

  def current_weather_keys
    %i[
        datetime
        sunrise
        sunset
        temperature
        feels_like
        humidity
        uvi
        visibility
        conditions
        icon
    ]
  end

  def daily_weather_keys
    %i[
        date
        sunrise
        sunset
        max_temp
        min_temp
        conditions
        icon
    ]
  end

  def hourly_weather_keys
    %i[
        time
        temperature
        conditions
        icon
    ]
  end
end

