require 'rails_helper'

describe CreateItem do
  let(:use_case) { CreateItem.new(external_id) }

  describe '#run' do
    subject { use_case.run }

    context 'when successful and no attributes are passed in' do
      let(:external_id) { '1234' }

      it { should be_truthy }

      it 'will provide the new item' do
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

    context 'when attributes are included' do
      let(:external_id) { '1234' }
      let(:attribute) { FactoryGirl.create :attribute }
      let(:attr_id_value_pair) { {attribute_id: attribute.id, value: '11'} }
      let(:use_case) { CreateItem.new(external_id, [attr_id_value_pair]) }

      it { should be_truthy }

      context 'when evaluating the object attributes' do
        before do
          use_case.run
          item = use_case.item
          @object_attr = ObjectAttribute.find_by(object_id: item.id)
        end

        it 'should create an object attribute for the item' do
          expect(@object_attr).to_not be_nil
          expect(@object_attr.associated_attribute).to eq attribute
          expect(@object_attr.value).to eq attr_id_value_pair[:value]
        end

        it 'should set the effective date to now' do
          expect(@object_attr.effective_date).to be_within(1.second).of(Time.now)
        end
      end

      context 'when there are 2 attributes' do
        let(:attribute2) { FactoryGirl.create :attribute, name: 'another attr' }
        let(:attr_id_value_pair2) { {attribute_id: attribute2.id, value: '37'} }
        let(:use_case) { CreateItem.new(external_id, [attr_id_value_pair, attr_id_value_pair2]) }

        before do
          use_case.run
          item = use_case.item
          @object_attrs = ObjectAttribute.where(object_id: item.id)
        end

        it 'should have created 2 object attributes' do
          expect(@object_attrs.count).to eq 2
        end
      end

      context 'when an attribute is not valid' do
        context 'when missing value' do
          let(:attribute) { FactoryGirl.create :attribute }
          let(:attr_id_value_pair) { {attribute_id: attribute.id} }
          let(:use_case) { CreateItem.new(external_id, [attr_id_value_pair]) }

          it { should be false }

          it 'will provide a validation error' do
            use_case.run
            expect(use_case.errors.keys.first).to eq :value
            expect(use_case.errors.values.first).to eq "can't be blank"
          end
        end
      end
    end
  end
end
