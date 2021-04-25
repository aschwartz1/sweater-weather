require 'rails_helper'

RSpec.describe 'Backgrounds' do
  describe 'Response Data' do
    it 'is correct' do
      allow_any_instance_of(Api::V1::BackgroundsController).to receive(:random_number).and_return(2)

      VCR.use_cassette('denver_background_request') do
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
  end

  describe 'sad path' do
    xit 'returns __what?__ when no images are found' do

    end
  end
end

=begin expected response structure
{
  id: nil,
  type: image,
  attributes: {
    image: {
      width: 444,
      height: 222,
      location: 'denver, co',
      title: 'buildings at midday',
      urls: {
        raw: 'https://unsplash.com/photo/path?utm_source=sweater_weather&utm_medium=referral',
        full: 'https://unsplash.com/photo/path?utm_source=sweater_weather&utm_medium=referral',
        regular: 'https://unsplash.com/photo/path?utm_source=sweater_weather&utm_medium=referral',
        small: 'https://unsplash.com/photo/path?utm_source=sweater_weather&utm_medium=referral',
        thumb: 'https://unsplash.com/photo/path?utm_source=sweater_weather&utm_medium=referral'
      }
    },
    credit: {
      author: {
        name: 'Annie Spratt',
        url: 'https://unsplash.com/@anniespratt?utm_source=sweater_weather&utm_medium=referral'
      },
      host: {
        name: 'Unsplash',
        url: 'https://unsplash.com?utm_source=sweater_weather&utm_medium=referral'
      }
    }
  }
}
=end
