class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A(\S+)@(.+)\.(\S+)\z/.freeze

  before_create :normalize_email
  before_validation :generate_api_key, on: :create

  validates :api_key, uniqueness: true, presence: true
  validates :email,
            uniqueness: true,
            presence: true,
            format: { with: VALID_EMAIL_REGEX }

  has_secure_password

  def self.find_and_authenticate(credentials)
    user = find_by(email: credentials[:email])
    return nil if user.nil?
    return nil unless user.authenticate(credentials[:password])

    user
  end

  private

  def normalize_email
    # Adding guard b/c shouldamatchers uniqueness check was failing without it
    self.email = email.downcase if email.present?
  end

  def generate_api_key
    self.api_key = SecureRandom.hex
  end
end
