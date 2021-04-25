require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should have_secure_password }
  end

  describe 'email validations' do
    it 'converts to lowercase before saving' do
      User.create(email: 'FOO@bar.COM', password: '1234')

      expect(User.first.email).to eq('foo@bar.com')
    end

    it 'rejects invalid email formats' do
      User.create(email: 'poop emoji', password: '1234')
      expect(User.count).to eq(0)

      User.create(email: 'bob@example', password: '1234')
      expect(User.count).to eq(0)

      User.create(email: '@example.com', password: '1234')
      expect(User.count).to eq(0)

      User.create(email: ' @example.com', password: '1234')
      expect(User.count).to eq(0)

      User.create(email: '" "@example.com', password: '1234')
      expect(User.count).to eq(0)
    end
  end
end
