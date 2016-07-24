require 'rails_helper'

describe CreateHoldCode do
  let(:use_case) { CreateHoldCode.new(code) }

  describe '#run' do
    subject { use_case.run }

    context 'when successful' do
      let(:code) { 'DAMAGED' }

      it { should be_truthy }

      it 'will provide the new hold code' do
        use_case.run
        hold_code = use_case.hold_code
        expect(hold_code.code).to eq code
      end
    end

    context 'when unsuccessful' do
      context 'when missing code' do
        let(:code) { nil }

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