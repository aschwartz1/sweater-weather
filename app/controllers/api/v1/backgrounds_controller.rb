class Api::V1::BackgroundsController < ApplicationController
  before_action :validate_params

  def show
    background_response = fetch_background(params[:location])
    background_response.id = nil

    render json: ImageSerializer.new(background_response)
  end

  private

  def validate_params
    # Desired format like `denver,co`
    render json: '', status: :bad_request and return if params[:location].blank?

    split = params[:location].split(',')
    # Location exists but is not in correct `city,state` format
    render json: '', status: :bad_request and return unless split.size == 2
    # Location seemed to be right format, but state was not a state code of 2 letters
    render json: '', status: :bad_request and return unless split.last.size == 2
  end

  # BEGIN BackgroundsService
  def background_connection
    @background_connection ||= Faraday.new 'https://api.unsplash.com' do |conn|
      conn.headers['Accept-Version'] = 'v1'
      conn.headers['Authorization'] = "#{ENV['unsplash_key']}"
    end
  end

  def fetch_background(location)
    city = location.split(',').first
    response = background_connection.get('search/photos') do |req|
      req.params[:query] = "#{city} skyline"
    end

    format_background_response(response)
  end

  def format_background_response(response)
    body = JSON.parse(response.body, symbolize_names: true)

    results = body[:results]
    image_result = results[random_number(results.size)]

    OpenStruct.new({
      image: parse_image_info(image_result),
      credit: parse_credit_info(image_result),
    })
  end

  def parse_image_info(image_result)
    {
      width: image_result[:width],
      height: image_result[:height],
      urls: {
        raw: "#{image_result[:urls][:raw]}&#{unsplash_utm_params}",
        full: "#{image_result[:urls][:full]}&#{unsplash_utm_params}",
        regular: "#{image_result[:urls][:regular]}&#{unsplash_utm_params}",
        small: "#{image_result[:urls][:small]}&#{unsplash_utm_params}",
        thumb: "#{image_result[:urls][:thumb]}&#{unsplash_utm_params}"
      }
    }
  end

  def parse_credit_info(image_result)
    {
      author: {
        name: image_result[:user][:name],
        url: "#{image_result[:user][:links][:html]}?#{unsplash_utm_params}"
      },
      host: {
        name: 'Unsplash',
        url: 'https://unsplash.com?utm_source=sweater_weather&utm_medium=referral'
      }
    }
  end

  def random_number(exclusive_max)
    rand(exclusive_max)
  end

  def unsplash_utm_params
    'utm_source=sweater_weather&utm_medium=referral'
  end
  # END BackgroundsService
end
