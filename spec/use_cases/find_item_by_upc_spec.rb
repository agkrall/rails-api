require 'rails_helper'

describe FindItemByUpc do
  let(:use_case) { FindItemByUpc.new(location_id, upc) }

  describe '#run' do
    subject { use_case.run }

    context 'when location not found' do
      let(:location_id) { 'unknown-location-id' }
      let(:upc) { 'ignored' }
      before { expect(Location).to receive(:find_by_id).with(location_id).and_return nil }
      it { is_expected.to be false }
    end

    context 'when location is found' do
      let(:location) { double Location }
      let(:location_id) { 'valid-location-id' }
      before { expect(Location).to receive(:find_by_id).with(location_id).and_return location }

      context 'when item is not found' do
        let(:upc) { 'unknown-upc' }
        before { expect(Item).to receive(:find_by_upc).with(upc).and_return nil }
        it { is_expected.to be false }
      end

      context 'when item is found' do
        let(:item) { FactoryGirl.create(:item) }
        let(:upc) { 'valid-upc' }

        before do
          expect(Item).to receive(:find_by_upc).with(upc).and_return item
          expect(RetrieveStockOnHand).to receive(:new).and_return soh_use_case
        end

        context 'when soh retrieval succeeds' do
          let(:soh) { 7.0 }
          let(:soh_use_case) { instance_double(RetrieveStockOnHand, run: true, stock_on_hand: soh) }

          it { is_expected.to be_truthy }

          describe '#item_info' do
            subject { use_case.item_info }
            before { use_case.run }

            it { should include "id" => item.id,
                                "external_id" => item.external_id,
                                "upc" => upc,
                                "in_stock" => soh }

            it 'provides some hard-coded (for now) attributes' do
              expect(subject['image_url']).to eq 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/Banana.png/489px-Banana.png'
              expect(subject['about']).to eq 'This product is AWESOME. So is Steve.'
            end
          end
        end

        context 'when soh retrieval fails' do
          let(:soh_use_case) { instance_double(RetrieveStockOnHand, run: false) }

          it { is_expected.to be false }
        end
      end
    end
  end
end
