class User < ApplicationRecord
  VALID_EMAIL_REGEX = %r{\A(\S+)@(.+)\.(\S+)\z}

  before_create :normalize_email

  has_secure_password
  validates :email,
              uniqueness: true,
              presence: true,
              format: { with: VALID_EMAIL_REGEX }

  private

  def normalize_email
    # Adding unless guard b/c shouldamatchers uniqueness check was failing without it
    self.email = email.downcase unless self.email.blank?
  end
end
