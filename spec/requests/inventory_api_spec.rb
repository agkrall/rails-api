require 'rails_helper'

describe 'Inventory API', :type => :request do
  let(:headers) { {"ACCEPT" => 'application/json'} }
  let(:external_transaction_id_1) { 'test external id 1' }
  let(:item_1) { FactoryGirl.create(:item) }
  let(:location_1) { FactoryGirl.create(:location) }
  let(:quantity_1) { -12.0 }
  let(:uom_code_1) { 'EA' }

  let(:external_transaction_id_2) { 'test external id 2' }
  let(:item_2) { FactoryGirl.create(:item) }
  let(:location_2) { FactoryGirl.create(:location) }
  let(:quantity_2) { 2.0 }
  let(:uom_code_2) { 'OZ' }

  describe 'PUT /inventory' do
    let(:payload) {
      {
          transaction_code: transaction_code,
          transactions: [
              {
                  external_transaction_id: external_transaction_id_1,
                  lines: [
                      {
                          item_id: item_1.id,
                          location_id: location_1.id,
                          quantity: quantity_1,
                          uom_code: uom_code_1,
                      }
                  ]
              },
              {
                  external_transaction_id: external_transaction_id_2,
                  lines: [
                      {
                          item_id: item_2.id,
                          location_id: location_2.id,
                          quantity: quantity_2,
                          uom_code: uom_code_2,
                      }
                  ]
              }
          ]
      }
    }

    context 'for an inventory adjustment' do
      let(:transaction_code) { 'InventoryAdjustment' }

      context 'when successful' do
        before do
          put '/inventory', params: payload, headers: headers
        end

        it 'responds with success' do
          expect(response).to have_content_type 'application/json'
          expect(response).to be_success
        end

        it 'persists inventory adjustments' do
          adjustments_1 = InventoryAdjustment.where(item: item_1).all
          expect(adjustments_1.count).to be 1
          adjustment_1 = adjustments_1.first
          expect(adjustment_1).to have_attributes external_transaction_id: external_transaction_id_1,
                                                  item: item_1,
                                                  location: location_1,
                                                  quantity: quantity_1,
                                                  uom_code: uom_code_1
          adjustments_2 = InventoryAdjustment.where(item: item_2).all
          expect(adjustments_2.count).to be 1
          adjustment_2 = adjustments_2.first
          expect(adjustment_2).to have_attributes external_transaction_id: external_transaction_id_2,
                                                  item: item_2,
                                                  location: location_2,
                                                  quantity: quantity_2,
                                                  uom_code: uom_code_2
        end
      end

      context 'when fails rolls back all transactions in request' do
        before do
          payload[:transactions].last[:lines].first[:item_id] = 'unknown ID'
          put '/inventory', params: payload, headers: headers
        end

        it 'responds with a failure status' do
          expect(response).to have_content_type 'application/json'
          expect(response).to have_http_status :internal_server_error
        end

        it 'will not persist any inventory adjustments' do
          expect(InventoryAdjustment.where(item: item_1).count).to be 0
          expect(InventoryAdjustment.where(item: item_2).count).to be 0
        end

        context 'error messages are internationalized' do
          context 'when language is not specified in header' do
            before { expect(headers['HTTP_ACCEPT_LANGUAGE']).to be_nil }

            it 'defaults to en' do
              response_json = JSON.parse(controller.response.body)
              expect(response_json['message']).to eq 'The application has encountered an unknown error. Please contact the system administrator.'
            end
          end

          context 'when specifying locale' do
            let(:headers) { {"ACCEPT" => 'application/json', "HTTP_ACCEPT_LANGUAGE" => 'fr'} }

            it 'will translate when translation is available' do
              response_json = JSON.parse(controller.response.body)
              expect(response_json['message']).to eq "L'application a rencontré une erreur inconnue. S'il vous plaît contacter l'administrateur du système."
            end
          end
        end
      end
    end

    context 'for an inventory count' do
      let(:transaction_code) { 'InventoryCount' }

      context 'when successful' do
        before do
          put '/inventory', params: payload, headers: headers
        end

        it 'responds with success' do
          expect(response).to have_content_type 'application/json'
          expect(response).to be_success
        end

        it 'persists inventory adjustments and counts' do
          adjustments_1 = InventoryAdjustment.where(item: item_1).all
          expect(adjustments_1.count).to be 1
          adjustment_1 = adjustments_1.first
          expect(adjustment_1).to have_attributes external_transaction_id: external_transaction_id_1,
                                                  item: item_1,
                                                  location: location_1,
                                                  quantity: quantity_1,
                                                  uom_code: uom_code_1
          count_1 = InventoryCount.find_by(inventory_adjustment: adjustment_1)
          expect(count_1.quantity).to eq quantity_1
          adjustments_2 = InventoryAdjustment.where(item: item_2).all
          expect(adjustments_2.count).to be 1
          adjustment_2 = adjustments_2.first
          expect(adjustment_2).to have_attributes external_transaction_id: external_transaction_id_2,
                                                  item: item_2,
                                                  location: location_2,
                                                  quantity: quantity_2,
                                                  uom_code: uom_code_2
          count_2 = InventoryCount.find_by(inventory_adjustment: adjustment_2)
          expect(count_2.quantity).to eq quantity_2
        end
      end

      context 'when fails rolls back all transactions in request' do
        before do
          payload[:transactions].last[:lines].first[:item_id] = 'unknown ID'
          put '/inventory', params: payload, headers: headers
        end

        it 'responds with a failure status' do
          expect(response).to have_content_type 'application/json'
          expect(response).to have_http_status :internal_server_error
        end

        it 'will not persist any inventory adjustments' do
          expect(InventoryAdjustment.where(item: item_1).count).to be 0
          expect(InventoryAdjustment.where(item: item_2).count).to be 0
        end
      end
    end
  end

  describe 'GET /items/:item_id/inventory' do
    let(:item) { item_1 }

    before do
      FactoryGirl.create :inventory_adjustment,
                         external_transaction_id: external_transaction_id_1,
                         item: item,
                         location: location_1,
                         quantity: quantity_1,
                         uom_code: uom_code_1
      FactoryGirl.create :inventory_adjustment,
                         external_transaction_id: external_transaction_id_2,
                         item: item,
                         location: location_2,
                         quantity: quantity_2,
                         uom_code: uom_code_2
      get "/items/#{item.id}/inventory", headers: headers
    end

    it 'responds with success' do
      expect(response).to have_content_type 'application/json'
      expect(response).to be_success
    end

    it 'returns item/location info' do
      json = JSON.parse(response.body)
      expect(json['inventory'].count).to be 2
      inventory_1 = json['inventory'].find { |i| i['location_id'] == location_1.id }
      expect(inventory_1).to include "item_id" => "#{item.id}", "stock_on_hand" => "#{quantity_1}"
      inventory_2 = json['inventory'].find { |i| i['location_id'] == location_2.id }
      expect(inventory_2).to include "item_id" => "#{item.id}", "stock_on_hand" => "#{quantity_2}"
    end
  end

  describe 'GET /locations/:location_id/inventory' do
    let(:location) { location_2 }

    before do
      FactoryGirl.create :inventory_adjustment,
                         external_transaction_id: external_transaction_id_1,
                         item: item_1,
                         location: location,
                         quantity: quantity_1,
                         uom_code: uom_code_1
      FactoryGirl.create :inventory_adjustment,
                         external_transaction_id: external_transaction_id_2,
                         item: item_2,
                         location: location,
                         quantity: quantity_2,
                         uom_code: uom_code_2
      get "/locations/#{location.id}/inventory", headers: headers
    end

    it 'responds with success' do
      expect(response).to have_content_type 'application/json'
      expect(response).to be_success
    end

    it 'returns item/location info' do
      json = JSON.parse(response.body)
      expect(json['inventory'].count).to be 2
      inventory_1 = json['inventory'].find { |i| i['item_id'] == item_1.id }
      expect(inventory_1).to include "location_id" => "#{location.id}", "stock_on_hand" => "#{quantity_1}"
      inventory_2 = json['inventory'].find { |i| i['item_id'] == item_2.id }
      expect(inventory_2).to include "location_id" => "#{location.id}", "stock_on_hand" => "#{quantity_2}"
    end
  end
end