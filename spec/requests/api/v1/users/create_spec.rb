require 'rails_helper'

RSpec.describe 'User Create', type: :request do
  describe 'Happy Path' do
    it 'is correct' do
      get api_v1_backgrounds_path(location: 'denver,co')

      expect(response).to be_successful
      body = JSON.parse(response.body, symbolize_names: true)

      image = body[:data][:attributes][:image]
      expect(image[:width]).to eq(5100)
      expect(image[:height]).to eq(3400)

      urls = image[:urls]
      expect(urls[:raw]).to eq('https://images.unsplash.com/photo-1602800458591-eddda28a498b?ixid=MnwyMjU5MjJ8MHwxfHNlYXJjaHwzfHxkZW52ZXIlMjBza3lsaW5lfGVufDB8fHx8MTYxOTMxNTkwMg&ixlib=rb-1.2.1&utm_source=sweater_weather&utm_medium=referral')
      expect(urls[:full]).to eq('https://images.unsplash.com/photo-1602800458591-eddda28a498b?crop=entropy&cs=srgb&fm=jpg&ixid=MnwyMjU5MjJ8MHwxfHNlYXJjaHwzfHxkZW52ZXIlMjBza3lsaW5lfGVufDB8fHx8MTYxOTMxNTkwMg&ixlib=rb-1.2.1&q=85&utm_source=sweater_weather&utm_medium=referral')
      expect(urls[:regular]).to eq('https://images.unsplash.com/photo-1602800458591-eddda28a498b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwyMjU5MjJ8MHwxfHNlYXJjaHwzfHxkZW52ZXIlMjBza3lsaW5lfGVufDB8fHx8MTYxOTMxNTkwMg&ixlib=rb-1.2.1&q=80&w=1080&utm_source=sweater_weather&utm_medium=referral')
      expect(urls[:small]).to eq('https://images.unsplash.com/photo-1602800458591-eddda28a498b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwyMjU5MjJ8MHwxfHNlYXJjaHwzfHxkZW52ZXIlMjBza3lsaW5lfGVufDB8fHx8MTYxOTMxNTkwMg&ixlib=rb-1.2.1&q=80&w=400&utm_source=sweater_weather&utm_medium=referral')
      expect(urls[:thumb]).to eq('https://images.unsplash.com/photo-1602800458591-eddda28a498b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwyMjU5MjJ8MHwxfHNlYXJjaHwzfHxkZW52ZXIlMjBza3lsaW5lfGVufDB8fHx8MTYxOTMxNTkwMg&ixlib=rb-1.2.1&q=80&w=200&utm_source=sweater_weather&utm_medium=referral')

      credit = body[:data][:attributes][:credit]
      author = credit[:author]
      expect(author.keys).to eq([:name, :url])
      expect(author[:name]).to eq('Andrew Coop')
      expect(author[:url]).to eq('https://unsplash.com/@andrewcoop?utm_source=sweater_weather&utm_medium=referral')

      host = credit[:host]
      expect(host[:name]).to eq('Unsplash')
      expect(host[:url]).to eq('https://unsplash.com?utm_source=sweater_weather&utm_medium=referral')
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
      headers = {
        'Content_Type' => 'application/json; charset=utf-8'
      }

      body = {
        email: 'me@example.com',
        password: 'foobar',
      }

      post api_v1_users_path(headers: headers, params: body, as: :json)

      expect(response).to have_http_status(400)
    end
  end
end
