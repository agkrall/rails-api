require 'rails_helper'

describe LocationsController do
  it { should route(:get, '/locations').to(action: :index) }
  it { should route(:post, '/locations').to(action: :create) }
  it { should route(:put, '/locations/1234').to(action: :update, id: '1234') }
  it { should route(:get, '/locations/1001').to(action: :show, id: '1001') }

  describe 'GET /locations/:id (show)' do
    let!(:location_id) { Location.create(external_id: 'abc123').id }

    describe 'when the location is found' do
      before do
        get :show, params: {id: location_id}
      end

      it { is_expected.to respond_with :success }

      it 'responds with the location' do
        response = JSON.parse(controller.response.body)
        expect(response['external_id']).to eq('abc123')
      end
    end

    describe 'when the location is not found' do
      before do
        get :show, params: {id: 'foo'}
      end

      it { is_expected.to respond_with :not_found }
    end

    context 'when external_id is truthy' do
      describe 'when the location is found' do
        before do
          get :show, params: {id: 'abc123', external_id: 'anything truthy'}
        end

        it { is_expected.to respond_with :success }

        it 'responds with the location' do
          response = JSON.parse(controller.response.body)
          expect(response['id']).to eq location_id
        end
      end

      describe 'when the location is not found' do
        before do
          get :show, params: {id: 'foo', external_id: 'anything truthy'}
        end

        it { is_expected.to respond_with :not_found }
      end
    end
  end

  describe 'GET /locations' do
    let!(:id_for_location1) { Location.create(external_id: '1001').id }
    let!(:id_for_location3) { Location.create(external_id: '1003').id }
    let!(:id_for_location2) { Location.create(external_id: '1002').id }

    before do
      get :index
    end

    it { is_expected.to respond_with :success }

    it 'responds with all locations in alpha order' do
      expected_response = {
        locations: [
          { id: id_for_location1, external_id: '1001' },
          { id: id_for_location2, external_id: '1002' },
          { id: id_for_location3, external_id: '1003' }
        ]
      }.to_json
      expect(controller.response.body).to eq(expected_response)
      expect(controller.response.header['Content-Type']).to include 'application/json'
    end
  end

  describe 'POST /locations' do
    let(:external_id) { '1234' }
    let(:use_case) { double CreateLocation }
    let(:payload) { { external_id: external_id } }

    context 'when successful' do
      let(:new_location) { FactoryGirl.create(:location, external_id: external_id) }

      before do
        expect(CreateLocation).to receive(:new).with(external_id).and_return use_case
        expect(use_case).to receive(:run).and_return new_location
        post :create, params: payload
      end

      it { is_expected.to respond_with :success }

      it 'responds with JSON representing the location' do
        expect(controller.response).to have_json_body({id: new_location.id, external_id: new_location.external_id})
      end
    end

    context 'when fails' do
      let(:errors) { { 'some' => 'validation errors' } }

      before do
        expect(use_case).to receive(:errors).and_return errors
        expect(CreateLocation).to receive(:new).with(external_id).and_return use_case
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

  describe 'PUT /locations' do
    let(:id) { SecureRandom.uuid }
    let(:external_id) { '1234' }
    let(:use_case) { double UpdateLocation }
    let(:update_location) { FactoryGirl.create(:location, external_id: external_id) }

    context 'when successful' do
      before do
        expect(Location).to receive(:find_by_id).with(id).and_return update_location
        expect(UpdateLocation).to receive(:new).with(update_location, external_id).and_return use_case
        expect(use_case).to receive(:run).and_return update_location
        put :update, params: {id: id, external_id: external_id}
      end

      it { is_expected.to respond_with :success }

      it 'responds with JSON representing the location' do
        expect(controller.response).to have_json_body({id: update_location.id, external_id: update_location.external_id})
      end

      context 'when location not found' do
        before do
          expect(Location).to receive(:find_by_id).with(id).and_return nil
          put :update, params: {id: id, external_id: external_id}
        end
        it { is_expected.to respond_with :not_found }
      end
    end

    context 'when fails' do
      let(:errors) { { 'some' => 'validation errors' } }

      before do
        expect(Location).to receive(:find_by_id).with(id).and_return update_location
        expect(use_case).to receive(:errors).and_return errors
        expect(UpdateLocation).to receive(:new).with(update_location, external_id).and_return use_case
        expect(use_case).to receive(:run).and_return false
        put :update, params: {id: id, external_id: external_id}
      end

      it { is_expected.to respond_with :bad_request }

      it 'responds with JSON communicating the validatiion error' do
        errors_json = JSON.parse(response.body)['errors']
        expect(errors_json).to eq errors
      end
    end
  end
end
