require 'rails_helper'
require 'shared_examples_for_models'

describe User do
  describe '#save' do
    subject do
      user = User.new(username: 'admin', password: 'password')
      user.save
      user.reload
    end

    it { is_expected.to have_attributes username: 'admin' }
    it { is_expected.to have_attributes password: 'password' }
    it_behaves_like 'a newly created model instance'
  end

  describe '#errors' do
    subject do
      user.validate
      user.errors
    end

    context 'when validation passes' do
      let(:user) { User.new(username: 'admin', password: 'password') }

      it { should be_empty }
    end

    context 'when validation fails' do
      context 'when username is missing' do
        subject { User.new(password: 'password') }
        it_behaves_like 'an instance with a validation error', :username, 'errors.messages.blank'
      end

      context 'when password is missing' do
        subject { User.new(username: 'admin') }
        it_behaves_like 'an instance with a validation error', :password, 'errors.messages.blank'
      end

      context 'when username is a duplicate' do
        subject { User.new(username: 'admin', password: 'password') }
        before { User.create(username: 'admin', password: 'password') }
        it_behaves_like 'an instance with a validation error', :username, 'errors.messages.taken'
      end
    end
  end
end
