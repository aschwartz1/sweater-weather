class Api::V1::UsersController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :validate_params_exist

  def create
    # JSON.parse(request.body.read)
  end

  private

  def user_params
    @user_params ||= params.permit(:email, :password, :password_confirmation).to_h
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
