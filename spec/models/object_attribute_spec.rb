require 'rails_helper'
require 'shared_examples_for_models'

describe ObjectAttribute do
  let(:attribute) { FactoryGirl.create :attribute }
  let(:item) { FactoryGirl.create :item }
  let(:eff_dt) { Time.zone.at(1250000000) }

  describe '#save' do
    subject do
      object_attribute = ObjectAttribute.new(associated_attribute: attribute, object_id: item.id,
                                             value: '53', effective_date: eff_dt)
      object_attribute.save
      object_attribute.reload
    end

    it { is_expected.to have_attributes attribute_id: attribute.id, object_id: item.id,
                                        value: '53', effective_date: eff_dt, end_date: nil }
    it_behaves_like 'a newly created model instance'
  end

  describe '#errors' do
    subject do
      object_attribute.validate
      object_attribute.errors
    end

    context 'when validation passes' do
      let(:object_attribute) { ObjectAttribute.new(associated_attribute: attribute, object_id: item.id,
                                                   value: '53', effective_date: eff_dt) }
      it { should be_empty }
    end

    context 'when attribute is missing' do
      subject { ObjectAttribute.new(object_id: item.id,
                                    value: '53', effective_date: eff_dt) }
      it_behaves_like 'an instance with a validation error', :associated_attribute, 'errors.messages.blank'
    end

    context 'when object_id is missing' do
      subject { ObjectAttribute.new(associated_attribute: attribute,
                                    value: '53', effective_date: eff_dt) }
      it_behaves_like 'an instance with a validation error', :object_id, 'errors.messages.blank'
    end

    context 'when value is missing' do
      subject { ObjectAttribute.new(associated_attribute: attribute, object_id: item.id,
                                    effective_date: eff_dt) }
      it_behaves_like 'an instance with a validation error', :value, 'errors.messages.blank'
    end

    context 'when effective_date is missing' do
      subject { ObjectAttribute.new(associated_attribute: attribute, object_id: item.id,
                                    value: '53') }
      it_behaves_like 'an instance with a validation error', :effective_date, 'errors.messages.blank'
    end
  end
end
