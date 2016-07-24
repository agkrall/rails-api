require 'rails_helper'

describe ApplicationController do
  controller do
    def index
      raise 'unhandled exception'
    end
  end

  describe 'system error handling' do
    let(:language_code) { nil }

    before do
      expect(controller.logger).to receive(:error).with 'System error: unhandled exception'
      request.env['HTTP_ACCEPT_LANGUAGE'] = language_code
      get :index
    end

    it { is_expected.to respond_with :internal_server_error }

    describe 'the response body' do
      context 'when the locale is not passed along in the request headers' do
        before { expect(language_code).to be_nil }

        it 'responds with a generic error message the default language (English)' do
          response_json = JSON.parse(controller.response.body)
          expect(response_json['message']).to eq 'The application has encountered an unknown error. Please contact the system administrator.'
        end
      end

      context 'when the locale is English' do
        let(:language_code) { 'en' }

        it 'responds with a generic error message in English' do
          response_json = JSON.parse(controller.response.body)
          expect(response_json['message']).to eq 'The application has encountered an unknown error. Please contact the system administrator.'
        end
      end

      context 'when the locale is French' do
        let(:language_code) { 'fr' }

        it 'responds with a generic error message in French' do
          response_json = JSON.parse(controller.response.body)
          expect(response_json['message']).to eq "L'application a rencontré une erreur inconnue. S'il vous plaît contacter l'administrateur du système."
        end
      end

      context 'when the locale is for a language we have not translated' do
        let(:language_code) { 'sq' }

        it 'responds with a generic error message the default language (English)' do
          response_json = JSON.parse(controller.response.body)
          expect(response_json['message']).to eq 'The application has encountered an unknown error. Please contact the system administrator.'
        end
      end
    end
  end

  describe 'internationalization' do
    context 'setting the locale using the HTTP_ACCEPT_LANGUAGE header' do
      subject { I18n.locale }

      before do
        @locale = I18n.locale
        expect(I18n.locale).to_not eq language_code
        request.env['HTTP_ACCEPT_LANGUAGE'] = language_code
        get :index
      end

      after { I18n.locale = @locale }

      context 'when we have a translation config' do
        let(:language_code) { 'fr' }
        it { should eq :fr }
      end

      context 'when we do not have a translation config' do
        let(:language_code) { 'az' }
        it { should eq :en }
      end
    end

    it 'should have a key for each language we translate' do
      locales_other_than_en = I18n.config.available_locales - [:en]
      expect(locales_other_than_en.count).to be > 0

      infor_english_translations = YAML.load_file("#{Rails.configuration.root}/config/locales/en.yml")['en']
      expect(infor_english_translations.keys.count).to be > 0

      # http://stackoverflow.com/a/19515209/5605846
      def flatten_hash(my_hash, parent=[])
        my_hash.flat_map do |key, value|
          case value
            when Hash then
              flatten_hash(value, parent+[key])
            else
              [(parent+[key]).join('.'), value]
          end
        end
      end

      key_value_pairs = flatten_hash(infor_english_translations)
      (0..(key_value_pairs.count - 1)).step(2) do |i|
        key = key_value_pairs[i]
        locales_other_than_en.each do |locale|
          unless I18n.exists?(key, locale)
            fail("There is no translation for '#{key}' in locale '#{locale}'.")
          end
        end
      end
    end
  end
end
