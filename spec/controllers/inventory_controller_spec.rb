require 'rails_helper'

describe InventoryController do
  it { should route(:put, '/inventory').to(action: :create_transaction) }
  it { should route(:get, '/items/123/inventory').to(action: :index, item_id: '123') }
  it { should route(:get, '/locations/123/inventory').to(action: :index, location_id: '123') }

  describe 'PUT /inventory' do
    let(:external_transaction_id) { 'test external id' }
    let(:item) { FactoryGirl.create(:item) }
    let(:location) { FactoryGirl.create(:location) }
    let(:quantity) { -12.0 }
    let(:uom_code) { 'EA' }
    let(:payload) {
      {
          transaction_code: transaction_code,
          transactions: [
              {
                  external_transaction_id: external_transaction_id,
                  lines: [
                      {
                          item_id: item.id,
                          location_id: location.id,
                          quantity: quantity,
                          uom_code: uom_code,
                      }
                  ]
              }
          ]
      }
    }

    context 'for inventory adjustments' do
      let(:use_case) { double CreateInventoryTransaction }
      let(:transaction_code) { 'InventoryAdjustment' }

      context 'when creating a single inventory adjustment' do
        before do
          expect(CreateInventoryTransaction).to receive(:new).with(external_transaction_id, item, location, quantity, uom_code).and_return use_case
        end

        context 'when successful' do
          before do
            expect(use_case).to receive(:run).and_return true
            put :create_transaction, params: payload
          end

          it { is_expected.to respond_with :success }

          it 'responds with empty JSON' do
            expect(response.body).to eq '{}'
          end
        end

        context 'when fails' do
          let(:errors) { {'some' => 'validation errors'} }

          before do
            expect(use_case).to receive(:run).and_return false
            expect(use_case).to receive(:errors).and_return errors
            put :create_transaction, params: payload
          end

          it { is_expected.to respond_with :bad_request }

          it 'responds with JSON communicating the validation error' do
            errors_json = JSON.parse(response.body)['errors']
            expect(errors_json).to eq errors
          end
        end
      end

      context 'when creating multiple inventory adjustments' do
        let(:use_case_2) { double CreateInventoryTransaction }
        let(:external_transaction_id_2) { 'test external id 2' }
        let(:item_2) { FactoryGirl.create(:item) }
        let(:location_2) { FactoryGirl.create(:location) }
        let(:quantity_2) { 2.0 }
        let(:uom_code_2) { 'OZ' }
        let(:payload) {
          {
              transaction_code: transaction_code,
              transactions: [
                  {
                      external_transaction_id: external_transaction_id,
                      lines: [
                          {
                              item_id: item.id,
                              location_id: location.id,
                              quantity: quantity,
                              uom_code: uom_code,
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

        before do
          expect(CreateInventoryTransaction).to receive(:new).with(external_transaction_id,
                                                                   item, location, quantity, uom_code).and_return use_case
        end

        context 'when successful' do
          context 'when a single line per adjustment' do
            before do
              expect(use_case).to receive(:run).and_return true
              expect(CreateInventoryTransaction).to receive(:new).with(external_transaction_id_2,
                                                                       item_2, location_2, quantity_2, uom_code_2).and_return use_case_2
              expect(use_case_2).to receive(:run).and_return true
              put :create_transaction, params: payload
            end

            it { is_expected.to respond_with :success }

            it 'responds with empty JSON' do
              expect(response.body).to eq '{}'
            end
          end

          context 'when multiple lines per adjustment' do
            let(:use_case_3) { double CreateInventoryTransaction }
            let(:item_3) { FactoryGirl.create(:item) }
            let(:location_3) { FactoryGirl.create(:location) }
            let(:quantity_3) { 21.3 }
            let(:uom_code_3) { 'MEH' }
            let(:use_case_4) { double CreateInventoryTransaction }
            let(:item_4) { FactoryGirl.create(:item) }
            let(:location_4) { FactoryGirl.create(:location) }
            let(:quantity_4) { 1.4 }
            let(:uom_code_4) { 'BOO' }
            let(:payload) {
              {
                  transaction_code: transaction_code,
                  transactions: [
                      {
                          external_transaction_id: external_transaction_id,
                          lines: [
                              {
                                  item_id: item.id,
                                  location_id: location.id,
                                  quantity: quantity,
                                  uom_code: uom_code,
                              },
                              {
                                  item_id: item_3.id,
                                  location_id: location_3.id,
                                  quantity: quantity_3,
                                  uom_code: uom_code_3,
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
                              },
                              {
                                  item_id: item_4.id,
                                  location_id: location_4.id,
                                  quantity: quantity_4,
                                  uom_code: uom_code_4,
                              }
                          ]
                      }
                  ]
              }
            }

            before do
              expect(CreateInventoryTransaction).to receive(:new).with(external_transaction_id_2,
                                                                       item_2, location_2, quantity_2, uom_code_2).and_return use_case_2
              expect(CreateInventoryTransaction).to receive(:new).with(external_transaction_id,
                                                                       item_3, location_3, quantity_3, uom_code_3).and_return use_case_3
              expect(CreateInventoryTransaction).to receive(:new).with(external_transaction_id_2,
                                                                       item_4, location_4, quantity_4, uom_code_4).and_return use_case_4
              expect(use_case).to receive(:run).and_return true
              expect(use_case_2).to receive(:run).and_return true
              expect(use_case_3).to receive(:run).and_return true
              expect(use_case_4).to receive(:run).and_return true
              put :create_transaction, params: payload
            end

            it { is_expected.to respond_with :success }

            it 'responds with empty JSON' do
              expect(response.body).to eq '{}'
            end
          end
        end

        context 'when fails' do
          let(:errors) { {'some' => 'validation errors'} }

          context 'on the first use case' do
            before do
              expect(use_case).to receive(:run).and_return false
              expect(use_case).to receive(:errors).and_return errors
              put :create_transaction, params: payload
            end

            it { is_expected.to respond_with :bad_request }

            it 'responds with JSON communicating the validation error from the use case that failed' do
              errors_json = JSON.parse(response.body)['errors']
              expect(errors_json).to eq errors
            end
          end

          context 'on another use case' do
            before do
              expect(use_case).to receive(:run).and_return true
              expect(CreateInventoryTransaction).to receive(:new).with(external_transaction_id_2,
                                                                       item_2, location_2, quantity_2, uom_code_2).and_return use_case_2
              expect(use_case_2).to receive(:run).and_return false
              expect(use_case_2).to receive(:errors).and_return errors
              put :create_transaction, params: payload
            end

            it { is_expected.to respond_with :bad_request }

            it 'responds with JSON communicating the validation error from the use case that failed' do
              errors_json = JSON.parse(response.body)['errors']
              expect(errors_json).to eq errors
            end
          end
        end
      end
    end

    context 'for inventory counts' do
      let(:use_case) { double CreateInventoryCount }
      let(:transaction_code) { 'InventoryCount' }

      context 'when creating a single inventory count' do
        before do
          expect(CreateInventoryCount).to receive(:new).with(item, location, quantity, external_transaction_id, uom_code).and_return use_case
        end

        context 'when successful' do
          before do
            expect(use_case).to receive(:run).and_return true
            put :create_transaction, params: payload
          end

          it { is_expected.to respond_with :success }

          it 'responds with empty JSON' do
            expect(response.body).to eq '{}'
          end
        end

        context 'when fails' do
          let(:errors) { {'some' => 'validation errors'} }

          before do
            expect(use_case).to receive(:run).and_return false
            expect(use_case).to receive(:errors).and_return errors
            put :create_transaction, params: payload
          end

          it { is_expected.to respond_with :bad_request }

          it 'responds with JSON communicating the validation error' do
            errors_json = JSON.parse(response.body)['errors']
            expect(errors_json).to eq errors
          end
        end
      end

      context 'when creating multiple inventory counts' do
        let(:use_case_2) { double CreateInventoryCount }
        let(:external_transaction_id_2) { 'test external id 2' }
        let(:item_2) { FactoryGirl.create(:item) }
        let(:location_2) { FactoryGirl.create(:location) }
        let(:quantity_2) { 2.0 }
        let(:uom_code_2) { 'OZ' }
        let(:payload) {
          {
              transaction_code: transaction_code,
              transactions: [
                  {
                      external_transaction_id: external_transaction_id,
                      lines: [
                          {
                              item_id: item.id,
                              location_id: location.id,
                              quantity: quantity,
                              uom_code: uom_code,
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

        before do
          expect(CreateInventoryCount).to receive(:new).with(item, location, quantity, external_transaction_id, uom_code).and_return use_case
        end

        context 'when successful' do
          context 'when a single line per count' do
            before do
              expect(use_case).to receive(:run).and_return true
              expect(CreateInventoryCount).to receive(:new).with(item_2, location_2, quantity_2, external_transaction_id_2,
                                                                 uom_code_2).and_return use_case_2
              expect(use_case_2).to receive(:run).and_return true
              put :create_transaction, params: payload
            end

            it { is_expected.to respond_with :success }

            it 'responds with empty JSON' do
              expect(response.body).to eq '{}'
            end
          end

          context 'when multiple lines per count' do
            let(:use_case_3) { double CreateInventoryCount }
            let(:item_3) { FactoryGirl.create(:item) }
            let(:location_3) { FactoryGirl.create(:location) }
            let(:quantity_3) { 21.3 }
            let(:uom_code_3) { 'MEH' }
            let(:use_case_4) { double CreateInventoryCount }
            let(:item_4) { FactoryGirl.create(:item) }
            let(:location_4) { FactoryGirl.create(:location) }
            let(:quantity_4) { 1.4 }
            let(:uom_code_4) { 'BOO' }
            let(:payload) {
              {
                  transaction_code: transaction_code,
                  transactions: [
                      {
                          external_transaction_id: external_transaction_id,
                          lines: [
                              {
                                  item_id: item.id,
                                  location_id: location.id,
                                  quantity: quantity,
                                  uom_code: uom_code,
                              },
                              {
                                  item_id: item_3.id,
                                  location_id: location_3.id,
                                  quantity: quantity_3,
                                  uom_code: uom_code_3,
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
                              },
                              {
                                  item_id: item_4.id,
                                  location_id: location_4.id,
                                  quantity: quantity_4,
                                  uom_code: uom_code_4,
                              }
                          ]
                      }
                  ]
              }
            }

            before do
              expect(CreateInventoryCount).to receive(:new).with(item_2, location_2, quantity_2, external_transaction_id_2,
                                                                 uom_code_2).and_return use_case_2
              expect(CreateInventoryCount).to receive(:new).with(item_3, location_3, quantity_3, external_transaction_id,
                                                                 uom_code_3).and_return use_case_3
              expect(CreateInventoryCount).to receive(:new).with(item_4, location_4, quantity_4, external_transaction_id_2,
                                                                 uom_code_4).and_return use_case_4
              expect(use_case).to receive(:run).and_return true
              expect(use_case_2).to receive(:run).and_return true
              expect(use_case_3).to receive(:run).and_return true
              expect(use_case_4).to receive(:run).and_return true
              put :create_transaction, params: payload
            end

            it { is_expected.to respond_with :success }

            it 'responds with empty JSON' do
              expect(response.body).to eq '{}'
            end
          end
        end

        context 'when fails' do
          let(:errors) { {'some' => 'validation errors'} }

          context 'on the first use case' do
            before do
              expect(use_case).to receive(:run).and_return false
              expect(use_case).to receive(:errors).and_return errors
              put :create_transaction, params: payload
            end

            it { is_expected.to respond_with :bad_request }

            it 'responds with JSON communicating the validation error from the use case that failed' do
              errors_json = JSON.parse(response.body)['errors']
              expect(errors_json).to eq errors
            end
          end

          context 'on another use case' do
            before do
              expect(use_case).to receive(:run).and_return true
              expect(CreateInventoryCount).to receive(:new).with(item_2, location_2, quantity_2, external_transaction_id_2,
                                                                 uom_code_2).and_return use_case_2
              expect(use_case_2).to receive(:run).and_return false
              expect(use_case_2).to receive(:errors).and_return errors
              put :create_transaction, params: payload
            end

            it { is_expected.to respond_with :bad_request }

            it 'responds with JSON communicating the validation error from the use case that failed' do
              errors_json = JSON.parse(response.body)['errors']
              expect(errors_json).to eq errors
            end
          end
        end
      end
    end
  end

  describe 'GET /items/:item_id/inventory' do
    let(:item) { FactoryGirl.create :item }
    let(:location_1) { FactoryGirl.create :location }
    let(:location_2) { FactoryGirl.create :location }
    let(:location_3) { FactoryGirl.create :location }
    let(:use_case_1) { instance_double(RetrieveStockOnHand, run: true, stock_on_hand: 2.4) }
    let(:use_case_2) { instance_double(RetrieveStockOnHand, run: true, stock_on_hand: 3.0) }
    let(:use_case_3) { instance_double(RetrieveStockOnHand, run: true, stock_on_hand: 0.0) }

    context 'with no request params' do
      before do
        expect(RetrieveStockOnHand).to receive(:new).with(item, location_1).and_return use_case_1
        expect(RetrieveStockOnHand).to receive(:new).with(item, location_2).and_return use_case_2
        expect(RetrieveStockOnHand).to receive(:new).with(item, location_3).and_return use_case_3
        get :index, params: {item_id: item.id}
      end

      it { is_expected.to respond_with :success }

      it 'should return the SOH for all item/locations' do
        inventory_json = JSON.parse(response.body)['inventory']
        expect(inventory_json.count).to be 3
        inventory_json.each { |i| expect(i['item_id']).to eq item.id }
        expect(inventory_json.find { |i| i['location_id'] == location_1.id }['stock_on_hand']).to eq 2.4
        expect(inventory_json.find { |i| i['location_id'] == location_2.id }['stock_on_hand']).to eq 3.0
        expect(inventory_json.find { |i| i['location_id'] == location_3.id }['stock_on_hand']).to eq 0.0
      end
    end

    context 'with location_id request param' do
      before do
        expect(RetrieveStockOnHand).to receive(:new).with(item, location_2).and_return use_case_2
        get :index, params: {item_id: item.id, location_id: location_2.id}
      end

      it { is_expected.to respond_with :success }

      it 'should return the SOH for a single location' do
        inventory_json = JSON.parse(response.body)['inventory']
        expect(inventory_json.count).to be 1
        expect(inventory_json[0]['item_id']).to eq item.id
        expect(inventory_json[0]['external_item_id']).to eq item.external_id
        expect(inventory_json[0]['location_id']).to eq location_2.id
        expect(inventory_json[0]['external_location_id']).to eq location_2.external_id
        expect(inventory_json[0]['stock_on_hand']).to eq 3.0
      end
    end
  end

  describe 'GET /locations/:location_id/inventory' do
    let(:location) { FactoryGirl.create :location, external_id: 'ext-id-42' }
    let(:item_1) { FactoryGirl.create :item, external_id: 'ext-id-1' }
    let(:item_2) { FactoryGirl.create :item, external_id: 'ext-id-2' }
    let(:item_3) { FactoryGirl.create :item, external_id: 'ext-id-3' }
    let(:use_case_1) { instance_double(RetrieveStockOnHand, run: true, stock_on_hand: 2.4) }
    let(:use_case_2) { instance_double(RetrieveStockOnHand, run: true, stock_on_hand: 3.0) }
    let(:use_case_3) { instance_double(RetrieveStockOnHand, run: true, stock_on_hand: 0.0) }

    context 'with no request params' do
      before do
        expect(RetrieveStockOnHand).to receive(:new).with(item_1, location).and_return use_case_1
        expect(RetrieveStockOnHand).to receive(:new).with(item_2, location).and_return use_case_2
        expect(RetrieveStockOnHand).to receive(:new).with(item_3, location).and_return use_case_3
        get :index, params: {location_id: location.id}
      end

      it { is_expected.to respond_with :success }

      it 'should return the SOH for all item/locations' do
        inventory_json = JSON.parse(response.body)['inventory']
        expect(inventory_json.count).to be 3
        inventory_json.each { |i| expect(i['location_id']).to eq location.id }
        expect(inventory_json.find { |i| i['item_id'] == item_1.id }['stock_on_hand']).to eq 2.4
        expect(inventory_json.find { |i| i['item_id'] == item_2.id }['stock_on_hand']).to eq 3.0
        expect(inventory_json.find { |i| i['item_id'] == item_3.id }['stock_on_hand']).to eq 0.0
      end

      it 'should return the external IDs for all item/locations' do
        inventory_json = JSON.parse(response.body)['inventory']
        expect(inventory_json.count).to be 3
        inventory_json.each { |i| expect(i['external_location_id']).to eq 'ext-id-42' }
        expect(inventory_json.find { |i| i['item_id'] == item_1.id }['external_item_id']).to eq 'ext-id-1'
        expect(inventory_json.find { |i| i['item_id'] == item_2.id }['external_item_id']).to eq 'ext-id-2'
        expect(inventory_json.find { |i| i['item_id'] == item_3.id }['external_item_id']).to eq 'ext-id-3'
      end
    end

    context 'with item_id request param' do
      before do
        expect(RetrieveStockOnHand).to receive(:new).with(item_2, location).and_return use_case_2
        get :index, params: {item_id: item_2.id, location_id: location.id}
      end

      it { is_expected.to respond_with :success }

      it 'should return the SOH for a single item' do
        inventory_json = JSON.parse(response.body)['inventory']
        expect(inventory_json.count).to be 1
        expect(inventory_json[0]['item_id']).to eq item_2.id
        expect(inventory_json[0]['external_item_id']).to eq item_2.external_id
        expect(inventory_json[0]['location_id']).to eq location.id
        expect(inventory_json[0]['external_location_id']).to eq location.external_id
        expect(inventory_json[0]['stock_on_hand']).to eq 3.0
      end
    end
  end
end
