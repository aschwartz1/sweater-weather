require 'rails_helper'

RSpec.describe 'Backgrounds Facade' do
  describe 'Structure' do
    it 'is correct' do
      VCR.use_cassette('denver_background_request') do
        result = BackgroundsFacade.fetch_background('denver,co')

        expect(result).to be_an(OpenStruct)
        expect(result).to respond_to(:id)
        expect(result).to respond_to(:image)
        expect(result).to respond_to(:credit)

        image = result.image
        expect(image).to be_a(Hash)
        expect(image.keys).to eq([:width, :height, :urls])
        expect(image[:width]).to be_an(Integer)
        expect(image[:height]).to be_an(Integer)
        expect(image[:urls]).to be_an(Hash)

        credit = result.credit
        expect(credit).to be_a(Hash)
        expect(credit.keys).to eq([:author, :host])
        expect(credit[:author]).to be_a(Hash)
        expect(credit[:host]).to be_a(Hash)

        urls = image[:urls]
        expect(urls[:raw]).to be_a(String)
        expect(urls[:full]).to be_a(String)
        expect(urls[:regular]).to be_a(String)
        expect(urls[:small]).to be_a(String)
        expect(urls[:thumb]).to be_a(String)

        author = credit[:author]
        expect(author).to be_a(Hash)
        expect(author.keys).to eq([:name, :url])
        expect(author[:name]).to be_a(String)
        expect(author[:url]).to be_a(String)

        host = credit[:author]
        expect(host).to be_a(Hash)
        expect(host.keys).to eq([:name, :url])
        expect(host[:name]).to be_a(String)
        expect(host[:url]).to be_a(String)
      end
    end

    describe 'Response Data' do
      it 'is correct' do
        allow(BackgroundsFacade).to receive(:random_number).and_return(2)

        VCR.use_cassette('denver_background_request') do
          result = BackgroundsFacade.fetch_background('denver,co')

          image = result.image
          expect(image[:width]).to eq(5100)
          expect(image[:height]).to eq(3400)

          urls = image[:urls]
          expect(urls[:raw]).to eq('https://images.unsplash.com/photo-1602800458591-eddda28a498b?ixid=MnwyMjU5MjJ8MHwxfHNlYXJjaHwzfHxkZW52ZXIlMjBza3lsaW5lfGVufDB8fHx8MTYxOTMxNTkwMg&ixlib=rb-1.2.1&utm_source=sweater_weather&utm_medium=referral')
          expect(urls[:full]).to eq('https://images.unsplash.com/photo-1602800458591-eddda28a498b?crop=entropy&cs=srgb&fm=jpg&ixid=MnwyMjU5MjJ8MHwxfHNlYXJjaHwzfHxkZW52ZXIlMjBza3lsaW5lfGVufDB8fHx8MTYxOTMxNTkwMg&ixlib=rb-1.2.1&q=85&utm_source=sweater_weather&utm_medium=referral')
          expect(urls[:regular]).to eq('https://images.unsplash.com/photo-1602800458591-eddda28a498b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwyMjU5MjJ8MHwxfHNlYXJjaHwzfHxkZW52ZXIlMjBza3lsaW5lfGVufDB8fHx8MTYxOTMxNTkwMg&ixlib=rb-1.2.1&q=80&w=1080&utm_source=sweater_weather&utm_medium=referral')
          expect(urls[:small]).to eq('https://images.unsplash.com/photo-1602800458591-eddda28a498b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwyMjU5MjJ8MHwxfHNlYXJjaHwzfHxkZW52ZXIlMjBza3lsaW5lfGVufDB8fHx8MTYxOTMxNTkwMg&ixlib=rb-1.2.1&q=80&w=400&utm_source=sweater_weather&utm_medium=referral')
          expect(urls[:thumb]).to eq('https://images.unsplash.com/photo-1602800458591-eddda28a498b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwyMjU5MjJ8MHwxfHNlYXJjaHwzfHxkZW52ZXIlMjBza3lsaW5lfGVufDB8fHx8MTYxOTMxNTkwMg&ixlib=rb-1.2.1&q=80&w=200&utm_source=sweater_weather&utm_medium=referral')

          credit = result.credit
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
  end
end
