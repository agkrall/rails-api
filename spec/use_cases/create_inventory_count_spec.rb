require 'rails_helper'

describe CreateInventoryCount do
  let(:item) { FactoryGirl.create :item }
  let(:location) { FactoryGirl.create :location }
  let(:quantity) { 4.0 }
  let(:external_transaction_id) { 'external-transaction-id' }
  let(:uom_code) { 'EA' }
  let(:retrieve_soh_use_case) { double RetrieveStockOnHand }
  let(:use_case) { CreateInventoryCount.new(item, location, quantity, external_transaction_id, uom_code) }

  shared_examples 'a new InventoryCount' do |expected_delta|
    it 'should create a new inventory adjustment record with a delta' do
      inventory_adjustment = InventoryAdjustment.find_by(external_transaction_id: external_transaction_id)
      expect(inventory_adjustment).to have_attributes(item_id: item.id,
                                                      location_id: location.id,
                                                      quantity: expected_delta,
                                                      uom_code: uom_code,
                                                      transaction_code: 'InventoryCount')
    end

    it 'should create a new inventory count record' do
      inventory_adjustment = InventoryAdjustment.find_by(external_transaction_id: external_transaction_id)
      inventory_count = InventoryCount.find_by(inventory_adjustment: inventory_adjustment)
      expect(inventory_count).to have_attributes(inventory_adjustment: inventory_adjustment, quantity: 4.0)
    end
  end

  describe '#run' do
    context 'when successful' do
      let(:previous_soh) { 0.0 }

      before do
        expect(RetrieveStockOnHand).to receive(:new).with(item, location).and_return retrieve_soh_use_case
        expect(retrieve_soh_use_case).to receive(:run).and_return true
        expect(retrieve_soh_use_case).to receive(:stock_on_hand).and_return previous_soh
      end

      subject { use_case.run }

      it { should be_truthy }

      context 'creates transaction records' do
        before { use_case.run }

        context 'when the previous stock count is zero' do
          let(:previous_soh) { 0.0 }

          it_behaves_like 'a new InventoryCount', 4.0
        end

        context 'when the previous stock count is less than the current stock count' do
          let(:previous_soh) { 2.5 }

          it_behaves_like 'a new InventoryCount', (4.0 - 2.5)
        end

        context 'when the previous stock count is equal to the current stock count' do
          let(:previous_soh) { quantity }

          it_behaves_like 'a new InventoryCount', 0.0
        end

        context 'when the previous stock count is greater than the current stock count' do
          let(:previous_soh) { 7.0 }

          it_behaves_like 'a new InventoryCount', (4.0 - 7.0)
        end
      end
    end
  end
end
