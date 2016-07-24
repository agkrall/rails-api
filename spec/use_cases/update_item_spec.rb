require 'rails_helper'

describe UpdateItem do
  let(:item) { FactoryGirl.create(:item) }
  let(:use_case) { UpdateItem.new(item, external_id) }

  describe '#run' do
    subject { use_case.run }

    context 'when successful' do
      let(:external_id) { '1234' }

      it { should be_truthy }

      it 'will provide the updated item' do
        use_case.run
        item = use_case.item
        expect(item.external_id).to eq external_id
      end
    end

    context 'when unsuccessful' do
      context 'when missing id' do
        let(:external_id) { nil }

        it { should be false }

        it 'will provide a validation error' do
          use_case.run
          expect(use_case.errors.keys.first).to eq :external_id
          expect(use_case.errors.values.first).to eq "can't be blank"
        end
      end
    end
  end
end
