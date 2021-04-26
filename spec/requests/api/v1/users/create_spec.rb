require 'rails_helper'

RSpec.describe 'User Create', type: :request do
  describe 'Happy Path' do
    it 'returns correct structure' do
      headers = {'Content-Type' => 'application/json'}
      body = {
        'email': 'me@example.com',
        'password': 'foobar',
        'password_confirmation': 'foobar'
      }

      post api_v1_users_path, headers: headers, params: body, as: :json

      expect(response).to have_http_status(201)
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

    it 'creates a user and gives them an api key' do
      headers = {'Content-Type' => 'application/json'}
      body = {
        'email': 'me@example.com',
        'password': 'foobar',
        'password_confirmation': 'foobar'
      }

      post api_v1_users_path, headers: headers, params: body, as: :json
      created_user = User.last

      expect(response).to have_http_status(201)
      body = JSON.parse(response.body, symbolize_names: true)
      data = body[:data]
      attributes = data[:attributes]

      expect(data[:id]).to eq(created_user.id.to_s)
      expect(attributes[:email]).to eq(created_user.email)
      expect(attributes[:api_key]).to eq(created_user.api_key)
    end
  end

  describe 'sad path' do
    xit 'returns error if passwords do not match' do
      # TODO: handled when trying to save a record
    end

    xit 'returns error if email is invalid' do
      # TODO: handled when trying to save a record
    end

    it 'returns error if required body params are not sent' do
      headers = {'Content-Type' => 'application/json'}
      body = {
        'email': 'me@example.com',
        'password': 'foobar'
      }

      post api_v1_users_path, headers: headers, params: body, as: :json
      expect(response).to have_http_status(400)
    end
  end
end
