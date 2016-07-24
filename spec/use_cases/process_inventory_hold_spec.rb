require 'rails_helper'

describe ProcessInventoryHold do
  let(:item) { FactoryGirl.create :item }
  let(:location) { FactoryGirl.create :location }
  let(:quantity) { 2.0 }
  let(:uom_code) { 'test uom code' }
  let(:external_transaction_id) { 'test external id' }
  let(:previous_hold_code_strings) { %w(QC DAMAGED) }
  let(:new_hold_code_strings) { %w(QC) }
  let!(:qc_hold_code) { FactoryGirl.create :hold_code, code: 'QC' }
  let(:create_inv_hold_use_case) { double CreateInventoryHold }
  let(:create_hold_code_use_case) { double CreateHoldCode }

  let(:use_case) { ProcessInventoryHold.new(external_transaction_id, item, location, quantity, uom_code,
                                            previous_hold_code_strings, new_hold_code_strings) }

  describe '#run' do
    subject { use_case.run }

    context 'when successful' do
      it { should be_truthy }

    end

    context 'when it encounters a previous hold code that does not exist' do
      let!(:qc_hold_code) { FactoryGirl.create :hold_code, code: 'QC' }
      let(:damaged_hold_code) { FactoryGirl.create :hold_code }

      before do
        expect(CreateHoldCode).to receive(:new).with('DAMAGED').and_return create_hold_code_use_case
        expect(create_hold_code_use_case).to receive(:run).and_return damaged_hold_code
      end

      it 'creates a new hold code' do
        use_case.run
      end
    end

    context 'when it encounters a new hold code that does not exist' do
      let(:previous_hold_code_strings) { %w(QC) }
      let(:new_hold_code_strings) { %w(QC QUARANTINE) }
      let(:quarantine_hold_code) { FactoryGirl.create :hold_code }

      before do
        expect(CreateHoldCode).to receive(:new).with('QUARANTINE').and_return create_hold_code_use_case
        expect(create_hold_code_use_case).to receive(:run).and_return quarantine_hold_code
      end

      it 'creates a new hold code' do
        use_case.run
      end
    end

    context 'when previous hold codes are empty' do
      let(:previous_hold_code_strings) { %w() }
      let(:new_hold_code_strings) { %w(QC QUARANTINE) }
      let(:quarantine_hold_code) { FactoryGirl.create :hold_code, code: 'QUARANTINE' }
      let(:hold_codes) { [qc_hold_code, quarantine_hold_code] }

      before do
        expect(CreateInventoryHold).to receive(:new)
                                         .with(external_transaction_id, item, location, quantity, uom_code, hold_codes)
                                         .and_return create_inv_hold_use_case
        expect(create_inv_hold_use_case).to receive(:run).and_return true
      end

      it 'creates one hold using the new hold codes' do
        use_case.run
      end
    end

    context 'when new hold codes are empty' do
      let(:previous_hold_code_strings) { %w(QC DAMAGED) }
      let(:new_hold_code_strings) { %w() }
      let(:damaged_hold_code) { FactoryGirl.create :hold_code, code: 'DAMAGED' }
      let(:hold_codes) { [qc_hold_code, damaged_hold_code] }
      let(:previous_bucket_hold_quantity) { quantity * -1 }

      before do
        expect(CreateInventoryHold).to receive(:new)
                                         .with(external_transaction_id, item, location, previous_bucket_hold_quantity, uom_code, hold_codes)
                                         .and_return create_inv_hold_use_case
        expect(create_inv_hold_use_case).to receive(:run).and_return true
      end

      it 'creates one hold using the previous hold codes and a negative quantity' do
        use_case.run
      end
    end

    context 'when previous and new hold codes are both non-empty' do
      let(:previous_hold_code_strings) { %w(QC DAMAGED) }
      let(:new_hold_code_strings) { %w(QC QUARANTINE) }
      let(:damaged_hold_code) { FactoryGirl.create :hold_code, code: 'DAMAGED' }
      let(:previous_hold_codes) { [qc_hold_code, damaged_hold_code] }
      let(:quarantine_hold_code) { FactoryGirl.create :hold_code, code: 'QUARANTINE' }
      let(:new_hold_codes) { [qc_hold_code, quarantine_hold_code] }
      let(:previous_bucket_hold_quantity) { quantity * -1 }
      let(:create_inv_hold_use_case_2) { double CreateInventoryHold }

      before do
        allow(CreateInventoryHold).to receive(:new)
                                         .with(external_transaction_id, item, location, previous_bucket_hold_quantity, uom_code, previous_hold_codes)
                                         .and_return create_inv_hold_use_case
        allow(CreateInventoryHold).to receive(:new)
                                         .with(external_transaction_id, item, location, quantity, uom_code, new_hold_codes)
                                         .and_return create_inv_hold_use_case_2
        allow(create_inv_hold_use_case).to receive(:run).and_return true
        allow(create_inv_hold_use_case_2).to receive(:run).and_return true
      end

      it 'creates a negative quantity hold using the previous hold codes' do
        expect(CreateInventoryHold).to receive(:new)
                                         .with(external_transaction_id, item, location, previous_bucket_hold_quantity, uom_code, previous_hold_codes)
                                         .and_return create_inv_hold_use_case
        expect(create_inv_hold_use_case).to receive(:run).and_return true
        use_case.run
      end

      it 'creates a positive quantity hold using the new hold codes' do
        expect(CreateInventoryHold).to receive(:new)
                                         .with(external_transaction_id, item, location, quantity, uom_code, new_hold_codes)
                                         .and_return create_inv_hold_use_case_2
        expect(create_inv_hold_use_case_2).to receive(:run).and_return true
        use_case.run
      end
    end
  end
end