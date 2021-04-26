require 'rails_helper'

RSpec.describe 'Sessions Create', type: :request do
  describe 'Happy Path' do
    it 'returns correct structure' do
      get api_v1_salaries_path(destination: 'dallas')

      expect(response).to be_successful
      body = JSON.parse(response.body, symbolize_names: true)

      expect(body.keys).to eq([:data])
      data = body[:data]

      expect(data.keys).to eq([:id, :type, :attributes])
      expect(data[:type]).to eq('salaries')
      expect(data[:id]).to be_nil
      expect(data[:attributes].keys).to eq([:destination, :forecast, :salaries])

      attributes = data[:attributes]
      expect(attributes[:destination]).to be_a(String)
      expect(attributes[:forecast]).to be_a(Hash)
      expect(attributes[:salaries]).to be_an(Array)

      forecast = attributes[:forecast]
      expect(forecast.keys).to eq([:summary, :temperature])
      expect(forecast[:summary]).to be_a(String)
      expect(forecast[:temperature]).to be_a(String)

      salaries = attributes[:salaries]
      expect(salaries.size).to eq(7)

      first = salaries.first
      expect(first).to be_a(Hash)
      expect(first.keys).to eq([:title, :min, :max])
      expect(first[:title]).to be_a(String)
      expect(first[:min]).to be_a(String)
      expect(first[:max]).to be_a(String)

      last = salaries.last
      expect(last).to be_a(Hash)
      expect(last.keys).to eq([:title, :min, :max])
      expect(last[:title]).to be_a(String)
      expect(last[:min]).to be_a(String)
      expect(last[:max]).to be_a(String)
    end

    xit 'returns weather info' do
    end

    xit 'returns each job title we want' do
    end

    xit 'do I have to check each job for its info?' do
    end
  end

  describe 'sad path' do
    xit 'returns 400 if query parameter is not present' do
    end
  end
end
