require 'rails_helper'
require 'shared_examples_for_models'

describe HoldCode do
  it { should have_and_belong_to_many(:inventory_holds) }

  describe '#save' do
    subject do
      hold_code = HoldCode.create!(code: 'QC')
    end

    it { is_expected.to have_attributes code: 'QC' }

    it_behaves_like 'a newly created model instance'
  end

  describe '#update_attributes' do
    subject do
      hold_code.update_attributes(code: 'DAMAGED')
      hold_code.errors
    end

    context 'when attempting to update code' do
      let(:hold_code) { FactoryGirl.create(:hold_code, code: 'QC') }

      it 'raises a validation error' do
        expect(subject.count).to be 1
        expect(subject.first).to eq [:code, "can't be modified"]
      end
    end
  end

  describe '#to_json' do
    subject { hold_code.to_json }

    let(:hold_code) { FactoryGirl.create(:hold_code) }

    it 'filters attributes' do
      expect(subject).to eq({code: hold_code.code}.to_json)
    end
  end

  describe '#errors' do
    subject do
      hold_code.validate
      hold_code.errors
    end

    context 'when validation passes' do
      let(:hold_code) { HoldCode.new(code: 'QC') }

      it { should be_empty }
    end

    context 'when validation fails' do
      context 'when code is missing' do
        subject { HoldCode.new }
        it_behaves_like 'an instance with a validation error', :code, 'errors.messages.blank'
      end

      context 'when code is a duplicate' do
        subject { HoldCode.new(code: 'QC') }
        before { HoldCode.create!(code: 'QC') }
        it_behaves_like 'an instance with a validation error', :code, 'errors.messages.taken'
      end
    end
  end
end