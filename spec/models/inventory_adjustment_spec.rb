require 'rails_helper'
require 'shared_examples_for_models'

describe InventoryAdjustment do
  let(:item) { FactoryGirl.create :item }
  let(:location) { FactoryGirl.create :location }

  describe '#save' do
    context 'when transaction_code is InventoryAdjustment' do
      subject do
        adjustment = InventoryAdjustment.new(external_transaction_id: 'test external id',
                                             item: item,
                                             location: location,
                                             quantity: 4.2,
                                             uom_code: 'EA',
                                             transaction_code: 'InventoryAdjustment')
        adjustment.save
        adjustment.reload
      end

      it { is_expected.to have_attributes external_transaction_id: 'test external id',
                                          item: item,
                                          location: location,
                                          quantity: 4.2,
                                          uom_code: 'EA',
                                          transaction_code: 'InventoryAdjustment' }
      it_behaves_like 'a newly created model instance'
    end

    context 'when transaction_code is InventoryCount' do
      subject do
        adjustment = InventoryAdjustment.new(external_transaction_id: 'test external id',
                                             item: item,
                                             location: location,
                                             quantity: 4.2,
                                             uom_code: 'EA',
                                             transaction_code: 'InventoryCount')
        adjustment.save
        adjustment.reload
      end

      it { is_expected.to have_attributes transaction_code: 'InventoryCount' }
    end
  end

  describe '#errors' do
    let(:external_transaction_id) { 'test external id' }
    let(:quantity) { 2.0 }
    let(:uom_code) { 'test uom code' }
    let(:transaction_code) { 'InventoryAdjustment' }
    let(:adjustment) { InventoryAdjustment.new(external_transaction_id: external_transaction_id,
                                               item: item,
                                               location: location,
                                               quantity: quantity,
                                               uom_code: uom_code,
                                               transaction_code: transaction_code) }
    subject do
      adjustment.validate
      adjustment.errors
    end

    context 'when validation passes' do
      it { should be_empty }
    end

    context 'when validation fails' do
      subject { adjustment }

      context 'when external transaction id is missing' do
        let(:external_transaction_id) { nil }
        it_behaves_like 'an instance with a validation error', :external_transaction_id, 'errors.messages.blank'
      end

      context 'when quantity is missing' do
        let(:quantity) { nil }
        it_behaves_like 'an instance with a validation error', :quantity, 'errors.messages.blank'
      end

      context 'when transaction_code is missing' do
        let(:transaction_code) { nil }
        it_behaves_like 'an instance with a validation error', :transaction_code, 'errors.messages.blank'
      end

      context 'when transaction_code is wrong' do
        let(:transaction_code) { 'wrong' }
        it_behaves_like 'an instance with a validation error', :transaction_code,
                        'errors.messages.value_is_not_valid', {value: 'wrong'}
      end

      context 'when uom_code is missing' do
        let(:uom_code) { nil }
        it_behaves_like 'an instance with a validation error', :uom_code, 'errors.messages.blank'
      end
    end
  end
end
