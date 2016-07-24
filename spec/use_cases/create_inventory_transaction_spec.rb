require 'rails_helper'

describe CreateInventoryTransaction do
  let(:item) { FactoryGirl.create :item }
  let(:location) { FactoryGirl.create :location }
  let(:quantity) { 2.0 }
  let(:uom_code) { 'test uom code' }
  let(:use_case) { CreateInventoryTransaction.new(external_transaction_id, item, location, quantity, uom_code) }

  describe '#run' do

    subject { use_case.run }

    context 'when successful' do
      let(:external_transaction_id) { 'test external id' }

      it { should be_truthy }

      it 'will create the inventory transaction' do
        use_case.run
        inventory_transaction = use_case.inventory_transaction
        expect(inventory_transaction.item).to eq item
      end
    end

    context 'when unsuccessful' do
      context 'when missing external_transaction_id' do
        let(:external_transaction_id) { nil }

        it { should be false }

        it 'will provide a validation error' do
          use_case.run
          expect(use_case.errors.keys.first).to eq :external_transaction_id
          expect(use_case.errors.values.first).to eq "can't be blank"
        end
      end
    end
  end
end
