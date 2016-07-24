require 'rails_helper'

describe CreateAttribute do
  let(:name) { 'name' }
  let(:type) { 'boolean' }
  let(:use_case) { CreateAttribute.new(name, type) }

  describe '#run' do
    context 'when successful' do
      subject { use_case.run }

      it { should be_truthy }

      it 'will provide the new attribute' do
        use_case.run
        attribute = use_case.attribute
        expect(attribute.name).to eq name
        expect(attribute.attribute_type).to eq type
      end
    end

    context 'when unsuccessful' do
      let(:attribute) { double(Attribute) }
      let(:errors) do
        e = ActiveModel::Errors.new(attribute)
        e.add :foo, "bar"
        e
      end
      before do
        expect(Attribute).to receive(:create).with({name: name, attribute_type: type}).and_return attribute
        expect(attribute).to receive(:errors).at_least(:once).and_return errors
        use_case.run
      end

      it 'will provide a hash of the errors' do
        expect(use_case.errors).to eq({foo: "bar"})
      end
    end
  end
end
