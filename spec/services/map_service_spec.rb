require_relative '../../app/services/map_service.rb'

require 'rails_helper'

RSpec.describe 'Forecast Service' do
  describe 'Fetch Geocoords' do
    describe 'happy path' do
      it 'returns correct structure and data' do
        result = MapService.fetch_geocoords('denver,co')

        expect(result).to be_an(OpenStruct)
        expect(result).to respond_to(:latitude)
        expect(result).to respond_to(:longitude)

        expect(result[:latitude]).to be_between(39, 40)
        expect(result[:longitude]).to be_between(-105, -104)
      end
    end
  end
end
