require 'rails_helper'

RSpec.describe 'Forecast Current Weather' do
  describe 'Fetching geocoords from city & state' do
    it 'works' do
      get api_v1_forecast_path

      expect(response).to be_successful
    end
  end

  describe 'sad path' do
    xit 'returns error if query params are not sent' do

    end
  end
end

