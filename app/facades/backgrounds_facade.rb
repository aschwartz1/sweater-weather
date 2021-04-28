class BackgroundsFacade
  def self.fetch_background(location)
    city = location.split(',').first
    response = background_connection.get('search/photos') do |req|
      req.params[:query] = "#{city} skyline"
    end

    format_background_response(response)
  end

  private_class_method

  def self.background_connection
    @background_connection ||= Faraday.new 'https://api.unsplash.com' do |conn|
      conn.headers['Accept-Version'] = 'v1'
      conn.headers['Authorization'] = ENV['unsplash_key']
    end
  end

  def self.format_background_response(response)
    body = JSON.parse(response.body, symbolize_names: true)

    results = body[:results]
    image_result = results[random_number(results.size)]

    OpenStruct.new({
      id: nil,
      image: parse_image_info(image_result),
      credit: parse_credit_info(image_result)
    })
  end

  def self.parse_image_info(image_result)
    {
      width: image_result[:width],
      height: image_result[:height],
      urls: parse_urls(image_result[:urls])
    }
  end

  def self.parse_urls(urls)
    {
      raw: "#{urls[:raw]}&#{unsplash_utm_params}",
      full: "#{urls[:full]}&#{unsplash_utm_params}",
      regular: "#{urls[:regular]}&#{unsplash_utm_params}",
      small: "#{urls[:small]}&#{unsplash_utm_params}",
      thumb: "#{urls[:thumb]}&#{unsplash_utm_params}"
    }
  end

  def self.parse_credit_info(image_result)
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

  def self.random_number(exclusive_max)
    rand(exclusive_max)
  end

  def self.unsplash_utm_params
    'utm_source=sweater_weather&utm_medium=referral'
  end
end
