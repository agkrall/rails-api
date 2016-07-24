require 'rails_helper'
require 'shared_examples_for_models'

describe Location do
  describe '#save' do
    subject do
      location = Location.new(external_id: '1234')
      location.save
      location.reload
    end

    it { is_expected.to have_attributes external_id: '1234' }
    it_behaves_like 'a newly created model instance'
  end

  describe '#errors' do
    subject do
      location.validate
      location.errors
    end

    context 'when validation passes' do
      let(:location) { Location.new(external_id: '1234') }

      it { should be_empty }
    end

    context 'when validation fails' do
      subject { location }

      context 'when id is missing' do
        let(:location) { Location.new }
        it_behaves_like 'an instance with a validation error', :external_id, 'errors.messages.blank'
      end

      context 'when id is a duplicate' do
        subject { Location.new(external_id: '1234') }
        before { Location.create(external_id: '1234') }
        it_behaves_like 'an instance with a validation error', :external_id, 'errors.messages.taken'
      end
    end
  end
end
