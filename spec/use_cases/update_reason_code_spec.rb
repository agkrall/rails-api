require 'rails_helper'

describe UpdateReasonCode do
  let(:reason_code) { FactoryGirl.create(:reason_code) }
  let(:use_case) { UpdateReasonCode.new(reason_code, description, impacts_soh) }

  describe '#run' do
    subject { use_case.run }

    context 'when successful' do
      let(:description) { 'Damaged at Amazon fulfillment center' }
      let(:impacts_soh) { false }

      it { should be_truthy }

      it 'will update the desription' do
        use_case.run
        reason_code = use_case.reason_code
        expect(reason_code.description).to eq description
      end

      it 'will update impacts soh' do
        use_case.run
        reason_code = use_case.reason_code
        expect(reason_code.impacts_soh).to eq impacts_soh
      end
    end

    context 'when unsuccessful' do
      context 'when missing description' do
        let(:description) { nil }
        let(:impacts_soh) { false }

        it { should be false }

        it 'will provide a validation error' do
          use_case.run
          expect(use_case.errors.keys.first).to eq :description
          expect(use_case.errors.values.first).to eq "can't be blank"
        end
      end

      context 'when missing impacts_soh' do
        let(:description) { 'Damaged at Amazon fulfillment center' }
        let(:impacts_soh) { nil }

        it { should be false }

        it 'will provide a validation error' do
          use_case.run
          expect(use_case.errors.keys.first).to eq :impacts_soh
          expect(use_case.errors.values.first).to eq "is not included in the list"
        end
      end
    end
  end
end
