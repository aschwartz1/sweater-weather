require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should have_secure_password }
  end

  describe 'saving' do
    describe 'email' do
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

    describe 'api_key' do
      after :each do
        allow(SecureRandom).to receive(:hex).and_call_original
      end

      it 'creates api key before saving' do
        user = create(:user)
        expect(user.api_key.to_s).to_not be_empty
      end

      it 'api key must be unique' do
        user1 = create(:user)

        allow(SecureRandom).to receive(:hex).and_return(user1.api_key)

        user2 = User.create(email: 'foo@example.com',
                              api_key: user1.api_key,
                              # password: 'password',
                              password_confirmation: 'xpassword')

        expect(user2.errors.messages).to_not be_empty
      end
    end
  end

  describe 'class methods' do
    describe '::find_and_authenticate' do
      it 'returns user if credentials are correct' do
        user = create(:user, :test)

        found = User.find_and_authenticate(email: user.email, password: user.password)

        expect(found.id).to eq(user.id)
      end

      it 'returns nil if no user is found' do
        user = create(:user, :test)

        found = User.find_and_authenticate(email: 'not_it@example.com', password: user.password)

        expect(found).to be_nil
      end

      it 'returns nil if credentials are incorrect' do
        user = create(:user, :test)

        found = User.find_and_authenticate(email: user.email, password: 'not_their_password')

        expect(found).to be_nil
      end
    end

    describe '::valid_api_key?' do
      it 'returns true if the key exists' do
        user = create(:user)
        expect(User.valid_api_key?(user.api_key)).to eq(true)
      end

      it 'returns false if the key does not exist' do
        expect(User.valid_api_key?('1234')).to eq(false)
      end
    end
  end
end
