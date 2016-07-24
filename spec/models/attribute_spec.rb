require 'rails_helper'
require 'shared_examples_for_models'

describe Attribute do
  describe '#save' do
    subject do
      attribute = Attribute.new(name: 'test name', attribute_type: 'string')
      attribute.save
      attribute.reload
    end

    it { is_expected.to have_attributes name: 'test name', attribute_type: 'string' }
    it_behaves_like 'a newly created model instance'
  end

  describe '#errors' do
    subject do
      attribute.validate
      attribute.errors
    end

    context 'when validation passes' do
      let(:attribute) { Attribute.new(name: 'test name', attribute_type: 'date') }

      it { should be_empty }

      it 'should allow certain data types' do
        %w(string number date boolean).each_with_index do |type, i|
          expect(Attribute.new(name: "test name #{i}", attribute_type: type))
        end
      end
    end

    context 'when validation fails' do
      context 'name' do
        context 'is missing' do
          subject { Attribute.new(attribute_type: 'string') }
          it_behaves_like 'an instance with a validation error', :name, 'errors.messages.blank'
        end

        context 'is a duplicate' do
          subject { Attribute.new(name: 'same test name', attribute_type: 'boolean') }
          before { Attribute.create(name: 'same test name', attribute_type: 'boolean') }
          it_behaves_like 'an instance with a validation error', :name, 'errors.messages.taken'
        end
      end

      context 'attribute_type' do
        context 'is missing' do
          subject { Attribute.new(name: 'test name') }
          it_behaves_like 'an instance with a validation error', :attribute_type, 'errors.messages.blank'
        end

        context 'is not a valid type' do
          subject { Attribute.new(name: 'test name', attribute_type: 'invalid') }
          it_behaves_like 'an instance with a validation error',
                          :attribute_type, 'errors.messages.value_is_not_valid', {value: 'invalid'}
        end
      end
    end
  end
end
