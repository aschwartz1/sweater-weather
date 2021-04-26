class Api::V1::RoadTripsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :validate_params_exist

  def create
    user = User.find_and_authenticate(credential_params)

    if user.present?
      render json: UsersSerializer.new(user)
    else
      render json: errors_serializer(['Invalid credentials']), status: :unauthorized
    end
  end

  private

  def credential_params
    @credential_params ||= parse_params
  end

  def parse_params
    return {} if request.body.read.blank?

    JSON.parse(request.body.read, symbolize_names: true)
  end

  def validate_params_exist
    render json: errors_serializer(['No params found in request body']), status: :bad_request unless all_params_exist?
  end

  def all_params_exist?
    expected = %i[email password]

    expected.all? do |param|
      credential_params.include?(param)
    end
  end

  def errors_serializer(messages)
    ErrorsSerializer.new(ostructify_errors(messages))
  end

  def ostructify_errors(error_messages)
    error_messages.map do |message|
      OpenStruct.new({
        id: nil,
        message: message
      })
    end
  end
end
