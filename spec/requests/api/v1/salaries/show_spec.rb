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

    it 'returns destination' do
      get api_v1_salaries_path(destination: 'dallas')

      expect(response).to be_successful
      body = JSON.parse(response.body, symbolize_names: true)
      destination = body[:data][:attributes][:destination]

      expect(destination).to eq('dallas')
    end

    it 'returns weather info' do
      get api_v1_salaries_path(destination: 'dallas')

      expect(response).to be_successful
      body = JSON.parse(response.body, symbolize_names: true)
      forecast = body[:data][:attributes][:forecast]

      expect(forecast[:summary]).to be_a(String)
      expect(forecast[:temperature]).to match(/-?\d{1,3} F/)
    end

    it 'returns each job title we want' do
      get api_v1_salaries_path(destination: 'dallas')

      expect(response).to be_successful
      body = JSON.parse(response.body, symbolize_names: true)
      salaries = body[:data][:attributes][:salaries]

      sorted_actual_job_titles = salaries.map { |salary| salary[:title] }.sort
      expect(sorted_actual_job_titles).to eq(sorted_expected_job_titles)
    end

    it 'each salary min & max contains... something?' do
      get api_v1_salaries_path(destination: 'dallas')

      expect(response).to be_successful
      body = JSON.parse(response.body, symbolize_names: true)
      salaries = body[:data][:attributes][:salaries]

      mins = salaries.map { |salary| salary[:min] }
      maxes = salaries.map { |salary| salary[:max] }

      # Honestly not sure how to test the numbers are there. Don't want to figure out a regex for it...
      expect(mins.all? { |str| str.present? }).to eq(true)
      expect(maxes.all? { |str| str.present? }).to eq(true)
    end
  end

  describe 'sad path' do
    it 'returns 400 if query parameter is not present' do
      get api_v1_salaries_path

      expect(response).to have_http_status(400)
    end
  end

  def sorted_expected_job_titles
    [
      'Data Analyst',
      'Data Scientist',
      'Mobile Developer',
      'QA Engineer',
      'Software Engineer',
      'Systems Administrator',
      'Web Developer'
    ]
  end
end
