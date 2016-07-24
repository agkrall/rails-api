require 'rails_helper'

describe SessionsController do
  it { should route(:post, '/sessions').to(action: :create) }

  describe 'POST /sessions' do
    let(:use_case) { double CreateSession }
    let(:user) { FactoryGirl.create :user}
    let(:username) { user.username }
    let(:password) { user.password }
    let(:payload) { { username: username, password: password } }

    context 'when successful' do
      before do
        expect(CreateSession).to receive(:new).with(username, password).and_return use_case
        expect(use_case).to receive(:run).and_return true
        expect(use_case).to receive(:id_token).and_return 'XYZ'
        post :create, params: payload
      end

      it { is_expected.to respond_with :success }

      it 'responds with JSON containing the JWT token' do
        expect(controller.response).to have_json_body({id_token: 'XYZ'})
      end
    end

    context 'when fails' do
      before do
        expect(CreateSession).to receive(:new).with(username, password).and_return use_case
        expect(use_case).to receive(:run).and_return false
        post :create, params: payload
      end

      it { is_expected.to respond_with :unauthorized }

      it 'responds with JSON communicating the error' do
        errors_json = JSON.parse(response.body)['message']
        expect(errors_json).to eq 'Invalid login'
      end
    end
  end
end
