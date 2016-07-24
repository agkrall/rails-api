require 'rails_helper'

describe ReasonCodesController do
  it { should route(:get, '/reason_codes').to(action: :index) }
  it { should route(:get, '/reason_codes/E').to(action: :show, code: 'E') }
  it { should route(:post, '/reason_codes').to(action: :create) }

  describe 'GET /reason_codes' do
    let!(:reason_code1) { FactoryGirl.create(:reason_code) }
    let!(:reason_code2) { FactoryGirl.create(:reason_code) }
    let!(:reason_code3) { FactoryGirl.create(:reason_code, code: '!first') }

    before do
      get :index
    end

    it { is_expected.to respond_with :success }

    it 'responds with all reason codes in alpha order' do
      expected_response = {
        reason_codes: [
          {code: reason_code3.code, description: reason_code3.description, impacts_soh: reason_code3.impacts_soh},
          {code: reason_code1.code, description: reason_code1.description, impacts_soh: reason_code1.impacts_soh},
          {code: reason_code2.code, description: reason_code2.description, impacts_soh: reason_code2.impacts_soh}
        ]
      }.to_json
      expect(controller.response.body).to eq(expected_response)
      expect(controller.response.header['Content-Type']).to include 'application/json'
    end
  end

  describe 'GET /reason_codes/:code (show)' do
    let!(:reason_code) { FactoryGirl.create(:reason_code) }

    describe 'when the reason_code is found' do
      before { get :show, params: {code: reason_code.code} }

      it { is_expected.to respond_with :success }

      it 'responds with the reason_code' do
        response = JSON.parse(controller.response.body)
        expect(response['code']).to eq(reason_code.code)
      end
    end

    describe 'when the reason_code is not found' do
      before { get :show, params: {code: 'foo'} }

      it { is_expected.to respond_with :not_found }
    end
  end

  describe 'POST /reason_codes' do
    let(:code) { 'E' }
    let(:description) { 'Damaged at Amazon fulfillment center' }
    let(:impacts_soh) { 'true' }
    let(:use_case) { double CreateReasonCode }
    let(:payload) { {code: code, description: description, impacts_soh: impacts_soh} }

    context 'when successful' do
      let(:reason_code) { FactoryGirl.create(:reason_code, code: code, description: description, impacts_soh: impacts_soh) }

      before do
        expect(CreateReasonCode).to receive(:new).with(code, description, impacts_soh).and_return use_case
        expect(use_case).to receive(:run).and_return reason_code
        post :create, params: payload
      end

      it { is_expected.to respond_with :success }

      it 'responds with JSON representing the reason code' do
        expect(controller.response).to have_json_body({ code: reason_code.code, description: reason_code.description, impacts_soh: reason_code.impacts_soh })
      end
    end

    context 'when fails' do
      let(:errors) { {'some' => 'validation errors'} }

      before do
        expect(use_case).to receive(:errors).and_return errors
        expect(CreateReasonCode).to receive(:new).with(code, description, impacts_soh).and_return use_case
        expect(use_case).to receive(:run).and_return false
        post :create, params: payload
      end

      it { is_expected.to respond_with :bad_request }

      it 'responds with JSON communicating the validation error' do
        errors_json = JSON.parse(response.body)['errors']
        expect(errors_json).to eq errors
      end
    end
  end

  describe 'PUT /reason_codes' do
    let(:code) { 'E' }
    let(:description) { 'Damaged at Amazon fulfillment center' }
    let(:impacts_soh) { 'true' }
    let(:use_case) { double UpdateReasonCode }
    let(:reason_code) { FactoryGirl.create(:reason_code, code: code) }

    context 'when successful' do
      before do
        expect(ReasonCode).to receive(:find_by_code).with(code).and_return reason_code
        expect(UpdateReasonCode).to receive(:new).with(reason_code, description, impacts_soh).and_return use_case
        expect(use_case).to receive(:run).and_return reason_code
        put :update, params: {code: code, description: description, impacts_soh: impacts_soh}
      end

      it { is_expected.to respond_with :success }

      it 'responds with JSON representing the reason code' do
        expect(controller.response).to have_json_body({code: code, description: reason_code.description, impacts_soh: reason_code.impacts_soh})
      end

      context 'when reason code not found' do
        before do
          expect(ReasonCode).to receive(:find_by_code).with(code).and_return nil
          put :update, params: {code: code, description: description, impacts_soh: impacts_soh}
        end
        it { is_expected.to respond_with :not_found }
      end
    end

    context 'when fails' do
      let(:errors) { { 'some' => 'validation errors' } }

      before do
        expect(ReasonCode).to receive(:find_by_code).with(code).and_return reason_code
        expect(use_case).to receive(:errors).and_return errors
        expect(UpdateReasonCode).to receive(:new).with(reason_code, description, impacts_soh).and_return use_case
        expect(use_case).to receive(:run).and_return false
        put :update, params: {code: code, description: description, impacts_soh: impacts_soh}
      end

      it { is_expected.to respond_with :bad_request }

      it 'responds with JSON communicating the validatiion error' do
        errors_json = JSON.parse(response.body)['errors']
        expect(errors_json).to eq errors
      end
    end
  end
end
