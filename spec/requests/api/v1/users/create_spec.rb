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
    it 'returns error if passwords do not match' do
      headers = {'Content-Type' => 'application/json'}
      body = {
        'email': 'me@example.com',
        'password': 'foobar',
        'password_confirmation': 'barfoo'
      }

      post api_v1_users_path, headers: headers, params: body, as: :json

      expect(response).to have_http_status(422)
      body = JSON.parse(response.body, symbolize_names: true)

      data = body[:data]
      expect(data).to be_an(Array)
      expect(data.size).to eq(1)

      first = data.first
      expect(first.keys).to eq([:id, :type, :attributes])

      attributes = first[:attributes]
      expect(attributes.keys).to eq([:message])
      expect(attributes[:message]).to eq("Password confirmation doesn't match Password")
    end

    it 'returns error if email is invalid' do
      headers = {'Content-Type' => 'application/json'}
      body = {
        'email': 'poop emoji',
        'password': 'foobar',
        'password_confirmation': 'foobar'
      }

      post api_v1_users_path, headers: headers, params: body, as: :json

      expect(response).to have_http_status(422)
      body = JSON.parse(response.body, symbolize_names: true)

      data = body[:data]
      expect(data).to be_an(Array)
      expect(data.size).to eq(1)

      first = data.first
      expect(first.keys).to eq([:id, :type, :attributes])

      attributes = first[:attributes]
      expect(attributes.keys).to eq([:message])
      expect(attributes[:message]).to eq("Email is invalid")
    end

    it 'returns error if required body params are not sent' do
      headers = {'Content-Type' => 'application/json'}

      post api_v1_users_path, headers: headers, params: body, as: :json
      expect(response).to have_http_status(400)
    end
  end
end
