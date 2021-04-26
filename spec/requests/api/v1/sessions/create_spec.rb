require 'rails_helper'

RSpec.describe 'Sessions Create', type: :request do
  before :each do
    @user = create(:user, :test)
    @headers = {'Content-Type' => 'application/json'}
  end

  describe 'Happy Path' do
    before :each do
      @body = {
        'email': 'test@example.com',
        'password': 'password'
      }
    end

    it 'returns correct structure' do
      post api_v1_sessions_path, headers: @headers, params: @body, as: :json

      expect(response).to be_successful
      body = JSON.parse(response.body, symbolize_names: true)

      expect(body.keys).to eq([:data])
      data = body[:data]

      expect(data.keys).to eq([:id, :type, :attributes])
      expect(data[:type]).to eq('users')
      expect(data[:id]).to be_a(String)
      expect(data[:attributes].keys).to eq([:email, :api_key])
      attributes = data[:attributes]

      expect(attributes[:email]).to be_a(String)
      expect(attributes[:api_key]).to be_a(String)
    end

    it 'returns users data, excluding password' do
      post api_v1_sessions_path, headers: @headers, params: @body, as: :json

      expect(response).to be_successful
      body = JSON.parse(response.body, symbolize_names: true)
      data = body[:data]
      attributes = data[:attributes]

      expect(data[:id]).to eq(@user.id.to_s)
      expect(attributes[:email]).to eq(@user.email)
      expect(attributes[:api_key]).to eq(@user.api_key)
    end
  end

  describe 'sad path' do
    it 'returns error with general message if password is invalid' do
      body = {
        'email': 'test@example.com',
        'password': 'thisisnotit',
      }

      post api_v1_sessions_path, headers: @headers, params: body, as: :json

      expect(response).to have_http_status(401)
      body = JSON.parse(response.body, symbolize_names: true)

      data = body[:data]
      expect(data).to be_an(Array)
      expect(data.size).to eq(1)

      first = data.first
      expect(first.keys).to eq([:id, :type, :attributes])

      attributes = first[:attributes]
      expect(attributes.keys).to eq([:message])
      expect(attributes[:message]).to eq("Invalid credentials")
    end

    it 'returns error with general message if password is invalid' do
      body = {
        'email': 'poop emoji',
        'password': 'password',
      }

      post api_v1_sessions_path, headers: @headers, params: body, as: :json

      expect(response).to have_http_status(401)
      body = JSON.parse(response.body, symbolize_names: true)

      data = body[:data]
      expect(data).to be_an(Array)
      expect(data.size).to eq(1)

      first = data.first
      expect(first.keys).to eq([:id, :type, :attributes])

      attributes = first[:attributes]
      expect(attributes.keys).to eq([:message])
      expect(attributes[:message]).to eq("Invalid credentials")
    end

    it 'returns error if required body params are not sent' do
      post api_v1_sessions_path, headers: @headers, params: body, as: :json
      expect(response).to have_http_status(400)
    end
  end
end
