require 'rails_helper'
require 'shared_examples_for_models'

describe InventoryCount do
  let(:adjustment) { FactoryGirl.create(:inventory_adjustment) }
  let(:count) { InventoryCount.new(inventory_adjustment: adjustment,
                                   quantity: quantity) }

  describe '#save' do
    let(:quantity) { 4.9 }
    subject do
      count.save
      count.reload
    end

    it { is_expected.to have_attributes inventory_adjustment: adjustment,
                                        quantity: quantity }
    it_behaves_like 'a newly created model instance'
  end

  describe '#errors' do
    subject do
      count.validate
      count.errors
    end

    context 'when validation passes' do
      let(:quantity) { 10 }

      it { should be_empty }
    end

    context 'when validation fails' do
      subject { count }

      context 'when quantity is missing' do
        let(:quantity) { nil }
        it_behaves_like 'an instance with a validation error', :quantity, 'errors.messages.blank'
      end
    end
  end
end
