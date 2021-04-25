class User < ApplicationRecord
  VALID_EMAIL_REGEX = %r{\A(\S+)@(.+)\.(\S+)\z}

  before_create :normalize_email
  before_validation :generate_api_key, on: :create

  validates :api_key, uniqueness: true, presence: true
  validates :email,
              uniqueness: true,
              presence: true,
              format: { with: VALID_EMAIL_REGEX }

  has_secure_password

  private

  def normalize_email
    # Adding unless guard b/c shouldamatchers uniqueness check was failing without it
    self.email = email.downcase unless self.email.blank?
  end

  def generate_api_key
    self.api_key = SecureRandom.hex
  end
end
