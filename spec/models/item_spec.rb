require 'rails_helper'
require 'shared_examples_for_models'

describe Item do
  describe '#save' do
    subject do
      item = Item.new(external_id: '1234')
      item.save
      item.reload
    end

    it { is_expected.to have_attributes external_id: '1234' }
    it_behaves_like 'a newly created model instance'
  end

  describe '#errors' do
    subject do
      item.validate
      item.errors
    end

    context 'when validation passes' do
      let(:item) { Item.new(external_id: '1234') }

      it { should be_empty }
    end

    context 'when validation fails' do
      subject { item }

      context 'when id is missing' do
        let(:item) { Item.new }
        it_behaves_like 'an instance with a validation error', :external_id, 'errors.messages.blank'
      end

      context 'when id is a duplicate' do
        subject { Item.new(external_id: '1234') }
        before { Item.create(external_id: '1234') }
        it_behaves_like 'an instance with a validation error', :external_id, 'errors.messages.taken'
      end
    end
  end

  describe '#object_attributes' do
    let(:item) { FactoryGirl.create :item }
    let!(:object_attribute_1) { ObjectAttribute.create!(associated_attribute: FactoryGirl.create(:attribute),
                                                        object_id: item.id,
                                                        value: '53',
                                                        effective_date: Time.zone.at(1250000000)) }
    let!(:object_attribute_2) { ObjectAttribute.create!(associated_attribute: FactoryGirl.create(:attribute),
                                                        object_id: item.id,
                                                        value: '54',
                                                        effective_date: Time.zone.at(1260000000)) }
    subject { item.object_attributes }

    before do
      another_item = FactoryGirl.create(:item)
      ObjectAttribute.create!(associated_attribute: FactoryGirl.create(:attribute),
                              object_id: another_item.id,
                              value: '54',
                              effective_date: Time.zone.at(1260000000))
    end

    it 'should be the expected size' do
      expect(subject.count).to be 2
    end

    it { should include object_attribute_1 }
    it { should include object_attribute_2 }
  end

  describe '::find_by_upc' do
    let(:item) { FactoryGirl.create :item }

    subject { Item.find_by_upc upc }

    context 'when there is no UPC associated with the item' do
      let(:upc) { 'anything' }
      before { expect(item.object_attributes).to be_empty }
      it { should be_nil }
    end

    context 'when there is a UPC associated with the item' do
      let(:upc) { 'A12345' }
      let(:upc_attr) { Attribute.create!(name: Attribute::NAME_UPC, attribute_type: 'string') }

      context 'when found' do
        before do
          FactoryGirl.create :object_attribute, associated_attribute: upc_attr, object_id: item.id, value: upc
        end

        it { should eq item }
      end

      context 'when not found' do
        let(:upc) { 'not found' }

        before do
          FactoryGirl.create :object_attribute, associated_attribute: upc_attr, object_id: item.id, value: 'a different upc'
        end

        it { should be_nil }
      end
    end
  end
end
