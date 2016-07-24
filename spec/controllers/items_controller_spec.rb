require 'rails_helper'

describe ItemsController do
  it { should route(:get, '/items').to(action: :index) }
  it { should route(:get, '/items/abc123').to(action: :show, id: 'abc123') }
  it { should route(:get, '/locations/abc123/items/search').to(action: :search_within_location, location_id: 'abc123') }
  it { should route(:post, '/items').to(action: :create) }

  describe 'GET /items' do
    let!(:id_for_item1) { Item.create(external_id: '1001').id }
    let!(:id_for_item3) { Item.create(external_id: '1003').id }
    let!(:id_for_item2) { Item.create(external_id: '1002').id }

    before do
      get :index
    end

    it { is_expected.to respond_with :success }

    it 'responds with all items in alpha order' do
      expected_response = {
        items: [
          {id: id_for_item1, external_id: '1001'},
          {id: id_for_item2, external_id: '1002'},
          {id: id_for_item3, external_id: '1003'}
        ]
      }.to_json
      expect(controller.response.body).to eq(expected_response)
      expect(controller.response.header['Content-Type']).to include 'application/json'
    end
  end

  describe 'GET /items/:id (show)' do
    let!(:item_id) { Item.create(external_id: 'abc123').id }

    describe 'when the item is found' do
      before do
        get :show, params: {id: item_id}
      end

      it { is_expected.to respond_with :success }

      it 'responds with the item' do
        response = JSON.parse(controller.response.body)
        expect(response['external_id']).to eq('abc123')
      end
    end

    describe 'when the item is not found' do
      before do
        get :show, params: {id: 'foo'}
      end

      it { is_expected.to respond_with :not_found }
    end

    context 'when external_id is truthy' do
      describe 'when the item is found' do
        before do
          get :show, params: {id: 'abc123', external_id: 'anything truthy'}
        end

        it { is_expected.to respond_with :success }

        it 'responds with the item' do
          response = JSON.parse(controller.response.body)
          expect(response['id']).to eq item_id
        end
      end

      describe 'when the item is not found' do
        before do
          get :show, params: {id: 'foo', external_id: 'anything truthy'}
        end

        it { is_expected.to respond_with :not_found }
      end
    end
  end

  describe 'GET /locations/:location_id/item/search' do
    let(:location_id) { 'location-id' }
    let(:upc) { 'upc' }

    context 'when use case fails' do
      let(:use_case) { instance_double(FindItemByUpc, run: false) }
      before do
        expect(FindItemByUpc).to receive(:new).with(location_id, upc).and_return use_case
        get :search_within_location, params: {location_id: location_id, upc: upc}
      end
      it { is_expected.to respond_with :not_found }
    end

    context 'when use case succeeds' do
      let(:info) { {"id" => 5, "external_id" => 'five', "other" => 'stuff'} }
      let(:use_case) { instance_double(FindItemByUpc, run: true, item_info: info) }
      before do
        expect(FindItemByUpc).to receive(:new).with(location_id, upc).and_return use_case
        get :search_within_location, params: {location_id: location_id, upc: upc}
      end
      it { is_expected.to respond_with :success }

      it 'responds with item info' do
        response_json = JSON.parse(controller.response.body)
        expect(response_json['item']).to eq info
      end
    end
  end

  describe 'POST /items' do
    let(:external_id) { '1234' }
    let(:use_case) { double CreateItem }
    let(:payload) { {external_id: external_id} }

    context 'when successful' do
      let(:new_item) { FactoryGirl.create(:item, external_id: external_id) }

      before do
        expect(CreateItem).to receive(:new).with(external_id, nil).and_return use_case
        expect(use_case).to receive(:run).and_return new_item
        post :create, params: payload
      end

      it { is_expected.to respond_with :success }

      it 'responds with JSON representing the item' do
        expect(controller.response).to have_json_body({id: new_item.id, external_id: new_item.external_id})
      end
    end

    context 'when fails' do
      let(:errors) { {'some' => 'validation errors'} }

      before do
        expect(use_case).to receive(:errors).and_return errors
        expect(CreateItem).to receive(:new).with(external_id, nil).and_return use_case
        expect(use_case).to receive(:run).and_return false
        post :create, params: payload
      end

      it { is_expected.to respond_with :bad_request }

      it 'responds with JSON communicating the validation error' do
        errors_json = JSON.parse(response.body)['errors']
        expect(errors_json).to eq errors
      end
    end

    context 'when the request includes attributes' do
      let(:attributes) { [] }
      let(:payload) { {external_id: external_id, attributes: attributes} }

      before do
        expect(CreateItem).to receive(:new).with(external_id, nil).and_return use_case
        expect(use_case).to receive(:run).and_return true
        post :create, params: payload
      end

      it { is_expected.to respond_with :success }
    end
  end

  describe 'PUT /items' do
    let(:id) { SecureRandom.uuid }
    let(:external_id) { '1234' }
    let(:use_case) { double UpdateItem }
    let(:update_item) { FactoryGirl.create :item }

    context 'when successful' do
      before do
        expect(Item).to receive(:find_by_id).with(id).and_return update_item
        expect(UpdateItem).to receive(:new).with(update_item, external_id).and_return use_case
        expect(use_case).to receive(:run).and_return update_item
        put :update, params: {id: id, external_id: external_id}
      end

      it { is_expected.to respond_with :success }

      it 'responds with JSON representing the item' do
        expect(controller.response).to have_json_body({id: update_item.id, external_id: update_item.external_id})
      end

      context 'when item not found' do
        before do
          expect(Item).to receive(:find_by_id).with(id).and_return nil
          put :update, params: {id: id, external_id: external_id}
        end
        it { is_expected.to respond_with :not_found }
      end
    end

    context 'when fails' do
      let(:errors) { {'some' => 'validation errors'} }

      before do
        expect(Item).to receive(:find_by_id).with(id).and_return update_item
        expect(use_case).to receive(:errors).and_return errors
        expect(UpdateItem).to receive(:new).with(update_item, external_id).and_return use_case
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
