require 'rails_helper'
require 'shared_examples_for_models'

describe InventoryHold do
  let(:item) { FactoryGirl.create :item }
  let(:location) { FactoryGirl.create :location }

  it { should have_and_belong_to_many(:hold_codes) }

  describe '#save' do
    subject do
      hold = InventoryHold.new(external_transaction_id: 'test external id',
                               item: item,
                               location: location,
                               quantity: 4.2,
                               uom_code: 'EA')
      hold.save
      hold.reload
    end

    it { is_expected.to have_attributes external_transaction_id: 'test external id',
                                        item: item,
                                        location: location,
                                        quantity: 4.2,
                                        uom_code: 'EA' }

    it_behaves_like 'a newly created model instance'
  end

  describe '#errors' do
    let(:external_transaction_id) { 'test external id' }
    let(:quantity) { 2.0 }
    let(:uom_code) { 'test uom code' }
    let(:hold) { InventoryHold.new(external_transaction_id: external_transaction_id,
                                   item: item,
                                   location: location,
                                   quantity: quantity,
                                   uom_code: uom_code) }

    subject do
      hold.validate
      hold.errors
    end

    context 'when validation passes' do
      it { should be_empty }
    end

    context 'when validation fails' do
      subject { hold }

      context 'when external transaction id is missing' do
        let(:external_transaction_id) { nil }
        it_behaves_like 'an instance with a validation error', :external_transaction_id, 'errors.messages.blank'
      end

      context 'when quantity is missing' do
        let(:quantity) { nil }
        it_behaves_like 'an instance with a validation error', :quantity, 'errors.messages.blank'
      end

      context 'when uom_code is missing' do
        let(:uom_code) { nil }
        it_behaves_like 'an instance with a validation error', :uom_code, 'errors.messages.blank'
      end
    end
  end
end