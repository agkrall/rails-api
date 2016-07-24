require 'rails_helper'

describe "Item API", :type => :request do
  before { @headers = { "ACCEPT" => "application/json"} }

  context 'list items' do
    before do
      @item1 = FactoryGirl.create(:item, external_id:'1003')
      @item2 = FactoryGirl.create(:item, external_id:'1001')
      @item3 = FactoryGirl.create(:item, external_id:'1002')
      get '/items', headers: @headers
    end

    it 'returns an array of JSON items in alpha order' do
      expect(response).to have_content_type('application/json')
      expect(response).to be_success
      expect(response).to have_json_body(
        {
          items: [
            { id: @item2.id, external_id: @item2.external_id },
            { id: @item3.id, external_id: @item3.external_id },
            { id: @item1.id, external_id: @item1.external_id }
          ]
        }
      )
    end
  end

  context 'create item' do
    context 'with valid data' do
      before { post '/items', params: { external_id: '9876' }, headers: @headers }

      it 'creates the item' do
        expect(response).to have_content_type('application/json')
        expect(response).to be_success
      end
    end

    context 'with missing external_id' do
      before { post '/items', headers: @headers }

      it 'returns validation errors' do
        expect(response).to have_content_type('application/json')
        expect(response).to have_http_status(:bad_request)
        expect(response).to have_json_body({errors: {external_id: "can't be blank"}})
      end
    end

    context 'with duplicate external_id' do
      before do
        @item1 = FactoryGirl.create(:item)
        post '/items', params: { external_id: @item1.external_id }, headers: @headers
      end

      it 'returns validation errors' do
        expect(response).to have_content_type('application/json')
        expect(response).to have_http_status(:bad_request)
        expect(response).to have_json_body({errors: {external_id: 'has already been taken'}})
      end
    end
  end

  context 'delete item' do
    context 'when the item exists' do
      before do
        @item = FactoryGirl.create(:item)
        delete "/items/#{@item.id}", headers: @headers
      end

      it 'returns not found' do
        expect(response).to have_content_type('application/json')
        expect(response).to have_http_status(:not_found)
        expect(response).to have_empty_body
      end
    end
  end

  context 'show item' do
    context 'when the item exists' do
      before do
        @item = FactoryGirl.create(:item)
        get "/items/#{@item.id}", headers: @headers
      end

      it 'returns a JSON item' do
        expect(response).to have_content_type('application/json')
        expect(response).to be_success
        expect(response).to have_json_body({ id: @item.id, external_id: @item.external_id })
      end
    end

    context "when the item doesn't exist" do
      before { get "/items/#{SecureRandom.uuid}", headers: @headers }

      it 'returns proper HTTP status' do
        expect(response).to have_content_type('application/json')
        expect(response).to have_http_status(:not_found)
        expect(response).to have_empty_body
      end
    end
  end

  context 'update item' do
    context 'when the item exists' do
      before do
        @item = FactoryGirl.create(:item)
        put "/items/#{@item.id}", params: {external_id: 'new external id'}, headers: @headers
      end

      it 'returns a JSON location' do
        expect(response).to have_content_type('application/json')
        expect(response).to be_success
        expect(response).to have_json_body({id: @item.id, external_id: 'new external id'})
      end
    end

    context "when the location doesn't exist" do
      before { put "/items/#{SecureRandom.uuid}", params: {external_id: 'new external id'}, headers: @headers }

      it 'returns proper HTTP status' do
        expect(response).to have_content_type('application/json')
        expect(response).to have_http_status(:not_found)
        expect(response).to have_empty_body
      end
    end
  end
end
