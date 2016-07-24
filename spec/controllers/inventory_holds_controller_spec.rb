require 'rails_helper'

describe InventoryHoldsController do
  it { should route(:post, '/inventory/holds').to(action: :create) }

  describe 'POST /inventory/holds' do
    let(:external_transaction_id) { 'test external id' }
    let(:item) { FactoryGirl.create(:item) }
    let(:location) { FactoryGirl.create(:location) }
    let(:quantity) { 7.0 }
    let(:uom_code) { 'EA' }
    let(:prev_hold_codes) { %w(QC DAMAGED) }
    let(:new_hold_codes) { %w(QC) }
    let(:payload) {
      {
        holds: [
          {
            external_transaction_id: external_transaction_id,
            item_id: item.id,
            location_id: location.id,
            quantity: quantity,
            uom_code: uom_code,
            previous_hold_codes: prev_hold_codes,
            new_hold_codes: new_hold_codes
          }
        ]
      }
    }
    let(:use_case) { double ProcessInventoryHold }

    context 'when successful' do
      before do
        expect(ProcessInventoryHold).to receive(:new)
                                          .with(external_transaction_id, item, location,
                                                quantity, uom_code, prev_hold_codes, new_hold_codes)
                                          .and_return use_case
        expect(use_case).to receive(:run).and_return true
        post :create, params: payload
      end

      it { is_expected.to respond_with :success }

      it 'responds with empty JSON' do
        expect(response.body).to eq '{}'
      end
    end

    context 'when fails' do
      before do
        expect(ProcessInventoryHold).to receive(:new)
                                          .with(external_transaction_id, item, location,
                                                quantity, uom_code, prev_hold_codes, new_hold_codes)
                                          .and_return use_case
        expect(use_case).to receive(:run).and_return false
        post :create, params: payload
      end

      it { is_expected.to respond_with :bad_request }
    end

    context 'when handling multiple holds' do
      let(:item2) { FactoryGirl.create(:item) }
      let(:location2) { FactoryGirl.create(:location) }
      let(:quantity2) { 47.0 }
      let(:uom_code2) { 'CS' }
      let(:payload) {
        {
          holds: [
            {
              external_transaction_id: external_transaction_id,
              item_id: item.id,
              location_id: location.id,
              quantity: quantity,
              uom_code: uom_code,
              previous_hold_codes: prev_hold_codes,
              new_hold_codes: new_hold_codes
            },
            {
              external_transaction_id: external_transaction_id,
              item_id: item2.id,
              location_id: location2.id,
              quantity: quantity2,
              uom_code: uom_code2,
              previous_hold_codes: prev_hold_codes,
              new_hold_codes: new_hold_codes
            }
          ]
        }
      }
      let(:use_case2) { double ProcessInventoryHold }

      before do
        expect(ProcessInventoryHold).to receive(:new)
                                          .with(external_transaction_id, item, location,
                                                quantity, uom_code, prev_hold_codes, new_hold_codes)
                                          .and_return use_case
        expect(use_case).to receive(:run).and_return true
        expect(ProcessInventoryHold).to receive(:new)
                                          .with(external_transaction_id, item2, location2,
                                                quantity2, uom_code2, prev_hold_codes, new_hold_codes)
                                          .and_return use_case2
        expect(use_case2).to receive(:run).and_return true
        post :create, params: payload
      end

      it { is_expected.to respond_with :success }

      it 'responds with empty JSON' do
        expect(response.body).to eq '{}'
      end
    end
  end
end