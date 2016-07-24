require 'rails_helper'

class Model
  attr_accessor :changed, :errors
  
  def initialize
      @changed = []
      @errors = {}
  end

  def persisted?
    true
  end
end

describe ImmutableValidator do
  let(:model) { Model.new}
  let(:validator) { ImmutableValidator.new({attributes: [:code]}) }

  describe 'validation' do
    subject do
      validator.validate_each(model, :code, 'hey there')
      model.errors
    end

    context 'when validation passes' do
      before { model.changed = []}

      it { should be_empty }
    end

    context 'when validation fails' do
      context 'without a custom message' do
        before do
          model.changed = ['code']
          model.errors[:code] = []
        end

        it 'communicates the validation error' do
          expect(subject.count).to be 1
          expect(subject.first).to eq [:code, ["can't be modified"]]
        end
      end

      context 'with a custom message' do
        let(:validator) { ImmutableValidator.new({attributes: [:code], message: "You have another thing coming"}) }

        before do
          model.changed = ['code']
          model.errors[:code] = []
        end

        it 'communicates the validation error' do
          expect(subject.count).to be 1
          expect(subject.first).to eq [:code, ["You have another thing coming"]]
        end
      end
    end
  end
end


