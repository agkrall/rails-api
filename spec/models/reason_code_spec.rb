require 'rails_helper'
require 'shared_examples_for_models'

describe ReasonCode do
  describe '#save' do
    subject do
      reason_code = ReasonCode.create!(code: 'E', description: 'Damaged at Amazon fulfillment center', impacts_soh: true)
    end

    it { is_expected.to have_attributes code: 'E' }
    it { is_expected.to have_attributes description: 'Damaged at Amazon fulfillment center' }
    it { is_expected.to have_attributes impacts_soh: true }
    it_behaves_like 'a newly created model instance'
  end

  describe '#update_attributes' do
    subject do
      reason_code.update_attributes(code: 'foo')
      reason_code.errors
    end

    context 'when attempting to update code' do
      let(:reason_code) { FactoryGirl.create(:reason_code, code: 'E') }

      it 'raises a validation error' do
        expect(subject.count).to be 1
        expect(subject.first).to eq [:code, "can't be modified"]
      end
    end
  end

  describe '#to_json' do
    subject { reason_code.to_json }

    let(:reason_code) { FactoryGirl.create(:reason_code) }

    it 'filters attributes' do
      expect(subject).to eq({code: reason_code.code, description: reason_code.description, impacts_soh: reason_code.impacts_soh}.to_json)
    end
  end

  describe '#errors' do
    subject do
      reason_code.validate
      reason_code.errors
    end

    context 'when validation passes' do
      let(:reason_code) { ReasonCode.new(code: 'E', description: 'Damaged at Amazon fulfillment center', impacts_soh: true) }

      it { should be_empty }
    end

    context 'when validation fails' do
      context 'when code is missing' do
        subject { ReasonCode.new(description: 'Damaged at Amazon fulfillment center', impacts_soh: true) }
        it_behaves_like 'an instance with a validation error', :code, 'errors.messages.blank'
      end

      context 'when code longer than 22 characters' do
        subject { ReasonCode.new(code: 'A'*23, description: 'Damaged at Amazon fulfillment center', impacts_soh: true) }
        it_behaves_like 'an instance with a validation error', :code, 'errors.messages.too_long.other', {count: 22}
      end

      context 'when code is a duplicate' do
        subject { ReasonCode.new(code: 'E', description: 'Damaged at Amazon fulfillment center', impacts_soh: true) }
        before { ReasonCode.create!(code: 'E', description: 'Damaged at Amazon fulfillment center', impacts_soh: true) }
        it_behaves_like 'an instance with a validation error', :code, 'errors.messages.taken'
      end

      context 'when description is missing' do
        subject { ReasonCode.new(code: 'E', impacts_soh: true) }
        it_behaves_like 'an instance with a validation error', :description, 'errors.messages.blank'
      end

      context 'when impacts_soh is missing' do
        subject { ReasonCode.new(code: 'E', description: 'Damaged at Amazon fulfillment center') }
        it_behaves_like 'an instance with a validation error', :impacts_soh, 'errors.messages.inclusion'
      end
    end
  end
end
