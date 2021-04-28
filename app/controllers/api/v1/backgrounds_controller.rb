class Api::V1::BackgroundsController < ApplicationController
  before_action :validate_params

  def show
    background_response = BackgroundsFacade.fetch_background(params[:location])

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
end
