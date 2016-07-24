require 'rails_helper'

describe CreateInventoryHold do
  let(:item) { FactoryGirl.create :item }
  let(:location) { FactoryGirl.create :location }
  let(:quantity) { 2.0 }
  let(:uom_code) { 'test uom code' }
  let(:external_transaction_id) { 'test external id' }
  let(:hold_codes) { FactoryGirl.create_list(:hold_code, 3) }
  let(:use_case) { CreateInventoryHold.new(external_transaction_id, item, location, quantity, uom_code, hold_codes) }

  describe '#run' do

    subject { use_case.run }

    context 'when successful' do
      it { should be_truthy }

      it 'will create the inventory hold' do
        use_case.run
        inventory_hold = use_case.inventory_hold
        expect(inventory_hold.item).to eq item
        expect(inventory_hold.hold_codes.count).to eq 3
      end
    end

    context 'when unsuccessful' do
      context 'when attempting to create an inventory hold' do
        let(:inv_hold) { double InventoryHold }
        let(:errors) do
          e = ActiveModel::Errors.new(inv_hold)
          e.add :external_transaction_id, "can't be blank"
          e
        end

        before do
          expect(InventoryHold).to receive(:new).with(external_transaction_id: external_transaction_id,
                                                      item: item, location: location, quantity: quantity,
                                                      uom_code: uom_code, hold_codes: hold_codes).and_return inv_hold
          expect(inv_hold).to receive(:save)
          expect(inv_hold).to receive(:errors).twice.and_return errors
        end

        it { should be false }

        it 'will return errors' do
          use_case.run
          expect(use_case.errors.keys.first).to eq :external_transaction_id
          expect(use_case.errors.values.first).to eq "can't be blank"
        end
      end
    end
  end
end