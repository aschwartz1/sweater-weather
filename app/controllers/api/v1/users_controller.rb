class Api::V1::UsersController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :validate_params_exist

  def create
    user = User.new(user_params)

    if user.save
      render json: UsersSerializer.new(user), status: :created
    elsif
      # render json: ErrorSerializer.new(user.errors.messages), status: :unprocessable_entity
    end
  end

  private

  def user_params
    @user_params ||= parse_params
  end

  def parse_params
    JSON.parse(request.body.read, symbolize_names: true)
  end

  def validate_params_exist
    render json: {}, status: :bad_request and return unless all_params_exist?
  end

  def all_params_exist?
    expected = %i{email password password_confirmation}

    expected.all? do |param|
      user_params.include?(param)
    end
  end
end
