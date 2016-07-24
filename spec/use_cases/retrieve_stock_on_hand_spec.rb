require 'rails_helper'

describe RetrieveStockOnHand do
  require 'rails_helper'
  let(:item) { FactoryGirl.create :item }
  let(:location) { FactoryGirl.create :location }
  let(:use_case) { RetrieveStockOnHand.new(item, location) }

  describe '#run' do
    context 'when successful' do
      subject { use_case.run }

      it { should be true }

      context 'it provides stock_on_hand' do
        subject { use_case.stock_on_hand }

        context 'when there are no existing inventory adjustments' do
          before do
            expect(InventoryAdjustment.find_by(item_id: item.id, location_id: location.id)).to be_nil
            use_case.run
          end

          it { should eq 0.0 }
        end

        context 'when there is a single existing inventory adjustment' do
          let(:first_adjustment_quantity) { 6.0 }

          before do
            create_inventory_adjustment first_adjustment_quantity
            expect(InventoryAdjustment.where(item_id: item.id, location_id: location.id).count).to be 1
            use_case.run
          end

          it { should eq first_adjustment_quantity }
        end

        context 'when there are several inventory adjustments with no stock counts' do
          before do
            create_inventory_adjustment 1.0
            create_inventory_adjustment 2.0
            create_inventory_adjustment 3.5
            use_case.run
          end

          it { should eq (1.0 + 2.0 + 3.5) }
        end

        context 'when there is an existing stock count' do
          context 'with no subsequent inventory adjustment' do
            let(:first_stock_count_quantity) { 8.0 }

            before do
              adjustment = create_inventory_adjustment(0.0, 'InventoryCount')
              InventoryCount.create(inventory_adjustment: adjustment,
                                    quantity: first_stock_count_quantity)
              expect(InventoryCount.where(inventory_adjustment: adjustment).count).to be 1
              use_case.run
            end

            it { should eq first_stock_count_quantity }
          end

          context 'with subsequent inventory adjustments' do
            let(:first_stock_count_quantity) { 8.0 }

            before do
              adjustment = create_inventory_adjustment(0.0, 'InventoryCount')
              InventoryCount.create(inventory_adjustment: adjustment,
                                    quantity: first_stock_count_quantity)
              create_inventory_adjustment 1.0, 'InventoryAdjustment'
              create_inventory_adjustment 2.2, 'InventoryAdjustment'
              use_case.run
            end

            it { should eq (first_stock_count_quantity + 1.0 + 2.2) }
          end
        end

        context 'when there are several existing stock counts' do
          let(:last_stock_count_quantity) { 7.0 }

          before do
            adjustment_1 = create_inventory_adjustment(2.0, 'InventoryCount')
            InventoryCount.create(inventory_adjustment: adjustment_1,
                                  quantity: 2.0)
            adjustment_2 = create_inventory_adjustment(0.0, 'InventoryCount')
            InventoryCount.create(inventory_adjustment: adjustment_2,
                                  quantity: 4.0)
            adjustment_3 = create_inventory_adjustment(3.0, 'InventoryCount')
            InventoryCount.create(inventory_adjustment: adjustment_3,
                                  quantity: last_stock_count_quantity)
          end

          context 'with no subsequent inventory adjustment' do
            before { use_case.run }

            it { should eq last_stock_count_quantity }
          end

          context 'with subsequent inventory adjustments' do
            before do
              create_inventory_adjustment 9.0
              create_inventory_adjustment -2.0
              use_case.run
            end

            it { should eq (last_stock_count_quantity + 9.0 - 2.0) }
          end
        end
      end
    end
  end

  private
  def create_inventory_adjustment(quantity, transaction_code = 'InventoryAdjustment')
    FactoryGirl.create :inventory_adjustment, item_id: item.id, location_id: location.id,
                       quantity: quantity, transaction_code: transaction_code
  end
end
