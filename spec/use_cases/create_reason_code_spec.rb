require 'rails_helper'

describe CreateReasonCode do
  let(:use_case) { CreateReasonCode.new(code, description, impacts_soh) }

  describe '#run' do
    subject { use_case.run }

    context 'when successful' do
      let(:code) { 'E' }
      let(:description) { 'Damaged at Amazon fulfillment center' }
      let(:impacts_soh) { true }

      it { should be_truthy }

      it 'will provide the new reason code' do
        use_case.run
        reason_code = use_case.reason_code
        expect(reason_code.code).to eq code
        expect(reason_code.description).to eq description
        expect(reason_code.impacts_soh).to eq impacts_soh
      end
    end

    context 'when unsuccessful' do
      context 'when missing code' do
        let(:code) { nil }
        let(:description) { 'Damaged at Amazon fulfillment center' }
        let(:impacts_soh) { true }

        it { should be false }

        it 'will provide a validation error' do
          use_case.run
          expect(use_case.errors.keys.first).to eq :code
          expect(use_case.errors.values.first).to eq "can't be blank"
        end
      end
    end
  end
end
