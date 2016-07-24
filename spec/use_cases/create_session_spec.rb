require 'rails_helper'

describe CreateSession do
  let(:use_case) { CreateSession.new(username, password) }

  describe '#run' do
    subject { use_case.run }

    context 'when successful' do
      let(:user) { FactoryGirl.create :user}
      let(:username) { user.username }
      let(:password) { user.password }

      it { should be_truthy }

      it 'will provide the JWT token' do
        use_case.run
        id_token = use_case.id_token
        expect(id_token).to eq JWT.encode({ id: user.id, username: user.username }, Rails.configuration.jwt_key)
      end

      it 'will provide the user' do
        use_case.run
        user = use_case.user
        expect(user.username).to eq username
        expect(user.password).to eq password
      end
    end

    context 'when unsuccessful' do
      context 'when user not found' do
        let(:username) { 'not found' }
        let(:password) { 'dont care' }
        
        it { should be false }
      end
    end
  end
end
