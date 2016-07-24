require 'rails_helper'

describe AttributesController do
  it { should route(:get, '/attributes').to(action: :index) }
  it { should route(:post, '/attributes').to(action: :create) }

  describe 'GET /attributes' do
    let!(:id_for_attibute_Z) { Attribute.create(name: 'Z attribute', attribute_type: 'number').id }
    let!(:id_for_attibute_a) { Attribute.create(name: 'a attribute', attribute_type: 'string').id }
    let!(:id_for_attibute_B) { Attribute.create(name: 'B attribute', attribute_type: 'date').id }

    before do
      get :index
    end

    it { is_expected.to respond_with :success }

    it 'responds with all attributes in alpha order' do
      response_json = JSON.parse(controller.response.body)['attributes']
      expect(response_json.count).to be 3
      expect(response_json[0]['id']).to eq id_for_attibute_a
      expect(response_json[0]['name']).to eq 'a attribute'
      expect(response_json[0]['attribute_type']).to eq 'string'
      expect(response_json[1]['id']).to eq id_for_attibute_B
      expect(response_json[1]['name']).to eq 'B attribute'
      expect(response_json[1]['attribute_type']).to eq 'date'
      expect(response_json[2]['id']).to eq id_for_attibute_Z
      expect(response_json[2]['name']).to eq 'Z attribute'
      expect(response_json[2]['attribute_type']).to eq 'number'
      expect(controller.response.header['Content-Type']).to include 'application/json'
    end

    it 'accommodates API v1' do
      response_json = JSON.parse(controller.response.body)['attributes']
      response_json.each do |attribute|
        expect(attribute['displayName']).to eq attribute['name']
        expect(attribute['attributeType']).to eq attribute['attribute_type']
      end
    end
  end

  describe 'POST /attributes' do
    let(:name) { 'test name' }
    let(:attribute_type) { 'test type' }
    let(:use_case) { double CreateAttribute }
    let(:payload) { {name: name, attribute_type: attribute_type} }

    context 'when successful' do
      let(:new_attribute) { FactoryGirl.create :attribute }

      before do
        expect(use_case).to receive(:attribute).and_return new_attribute
        expect(CreateAttribute).to receive(:new).with(name, attribute_type).and_return use_case
        expect(use_case).to receive(:run).and_return true
        post :create, params: payload
      end

      it { is_expected.to respond_with :success }

      it 'responds with JSON representing the new attribute' do
        attribute_json = JSON.parse(response.body)['attribute']
        expect(attribute_json['name']).to eq new_attribute.name
        expect(attribute_json['attribute_type']).to eq new_attribute.attribute_type
        expect(attribute_json['id']).to eq new_attribute.id
      end
    end

    context 'when fails' do
      let(:errors) { {'some' => 'validation errors'} }

      before do
        expect(use_case).to receive(:errors).at_least(:once).and_return errors
        expect(CreateAttribute).to receive(:new).with(name, attribute_type).and_return use_case
        expect(use_case).to receive(:run).and_return false
        post :create, params: payload
      end

      it { is_expected.to respond_with :bad_request }

      it 'responds with JSON communicating the validatiion error' do
        errors_json = JSON.parse(response.body)['errors']
        expect(errors_json).to eq errors
      end
    end
  end
end
