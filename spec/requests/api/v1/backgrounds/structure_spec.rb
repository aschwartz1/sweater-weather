require 'rails_helper'

RSpec.describe 'Backgrounds' do
  describe 'General Structure' do
    it 'is correct' do
      VCR.use_cassette('denver_background_request') do
        get api_v1_background_path(location: 'denver,co')

        expect(response).to be_successful
        body = JSON.parse(response.body, symbolize_names: true)

        expect(body.length).to eq(1)
        expect(body[:data]).to be_a(Hash)
        expect(body[:data].length).to eq(3)

        data = body[:data]
        expect(data.keys).to eq([:id, :type, :attributes])
        expect(data[:id]).to eq(nil)
        expect(data[:type]).to eq('image')
        expect(data[:attributes]).to be_a(Hash)
        attributes = data[:attributes]
        expect(attributes.keys).to eq([:image, :credit])

        image = attributes[:image]
        expect(image.keys).to eq([:id, :width, :height, :location, :title, :urls])
        urls = image[:urls]
        expect(urls.keys).to eq([:raw, :full, :regular, :small, :thumb])

        credit = attributes[:credit]
        author = credit[:author]
        expect(author.keys).to eq([:name, :url])
        host = credit[:host]
        expect(host.keys).to eq([:name, :url])
      end
    end
  end

  describe 'sad path' do
    it 'returns error if query params are not sent' do
      get api_v1_background_path
      expect(response).to have_http_status(400)
    end

    it 'returns error if location param is not the right format' do
      get api_v1_background_path(location: 'denver,colorado')
      expect(response).to have_http_status(400)
    end
  end

  def structure
    {
      id: nil,
      type: image,
      attributes: {
        image: {
          id: 1,
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
  end
end

