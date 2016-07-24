require 'rails_helper'

describe "Location API", :type => :request do
  before { @headers = { "ACCEPT" => "application/json"} }

  context 'list locations' do
    before do
      @location1 = FactoryGirl.create(:location, external_id:'1003')
      @location2 = FactoryGirl.create(:location, external_id:'1001')
      @location3 = FactoryGirl.create(:location, external_id:'1002')
      get '/locations', headers: @headers
    end

    it 'returns an array of JSON locations in alpha order' do
      expect(response).to have_content_type('application/json')
      expect(response).to be_success
      expect(response).to have_json_body(
        {
          locations: [
            { id: @location2.id, external_id: @location2.external_id },
            { id: @location3.id, external_id: @location3.external_id },
            { id: @location1.id, external_id: @location1.external_id }
          ]
        }
      )
    end
  end

  context 'create location' do
    context 'with valid data' do
      before { post '/locations', params: { external_id: '9876' }, headers: @headers }

      it 'creates the location' do
        expect(response).to have_content_type('application/json')
        expect(response).to be_success
      end
    end

    context 'with missing external_id' do
      before { post '/locations', headers: @headers }

      it 'returns validation errors' do
        expect(response).to have_content_type('application/json')
        expect(response).to have_http_status(:bad_request)
        expect(response).to have_json_body({errors: {external_id: "can't be blank"}})
      end
    end

    context 'with duplicate external_id' do
      before do
        @location1 = FactoryGirl.create(:location)
        post '/locations', params: { external_id: @location1.external_id }, headers: @headers
      end

      it 'returns validation errors' do
        expect(response).to have_content_type('application/json')
        expect(response).to have_http_status(:bad_request)
        expect(response).to have_json_body({errors: {external_id: 'has already been taken'}})
      end
    end
  end

  context 'delete location' do
    context 'when the location exists' do
      before do
        @location = FactoryGirl.create(:location)
        delete "/locations/#{@location.id}", headers: @headers
      end

      it 'returns not found' do
        expect(response).to have_content_type('application/json')
        expect(response).to have_http_status(:not_found)
        expect(response).to have_empty_body
      end
    end
  end

  context 'show location' do
    context 'when the location exists' do
      before do
        @location = FactoryGirl.create(:location)
        get "/locations/#{@location.id}", headers: @headers
      end

      it 'returns a JSON location' do
        expect(response).to have_content_type('application/json')
        expect(response).to be_success
        expect(response).to have_json_body({ id: @location.id, external_id: @location.external_id })
      end
    end

    context "when the location doesn't exist" do
      before { get "/locations/#{SecureRandom.uuid}", headers: @headers }

      it 'returns proper HTTP status' do
        expect(response).to have_content_type('application/json')
        expect(response).to have_http_status(:not_found)
        expect(response).to have_empty_body
      end
    end
  end

  context 'update location' do
    context 'when the location exists' do
      before do
        @location = FactoryGirl.create(:location)
        put "/locations/#{@location.id}", params: {external_id: 'new external id'}, headers: @headers
      end

      it 'returns a JSON location' do
        expect(response).to have_content_type('application/json')
        expect(response).to be_success
        expect(response).to have_json_body({id: @location.id, external_id: 'new external id'})
      end
    end

    context "when the location doesn't exist" do
      before { put "/locations/#{SecureRandom.uuid}", params: {external_id: 'new external id'}, headers: @headers }

      it 'returns proper HTTP status' do
        expect(response).to have_content_type('application/json')
        expect(response).to have_http_status(:not_found)
        expect(response).to have_empty_body
      end
    end
  end
end
