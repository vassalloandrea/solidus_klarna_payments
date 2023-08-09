# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Admin::PaymentMethodsController do
  describe '#update' do
    def make_request(payment_method_params)
      patch(
        "/admin/payment_methods/#{payment_method.id}",
        params: {
          id: payment_method.to_param,
          payment_method: payment_method_params
        }
      )
    end

    def stub_validate_klarna_credentials_service
      allow(SolidusKlarnaPayments::ValidateKlarnaCredentialsService)
        .to receive(:call)
    end

    let(:payment_method) { create(:klarna_credit_payment_method) }

    before { login_as create(:admin_user) }

    it 'does call the validate klarna creadentials service when the payment method type is klarna and is using static preferences' do
      stub_validate_klarna_credentials_service

      Spree::Config.static_model_preferences.add(
        'Spree::PaymentMethod::KlarnaCredit',
        'solidus_klarna_payments_env_credentials',
        api_key: 'STATIC_API_KEY',
        api_secret: 'STATIC_API_SECRET',
        country: 'it',
        test_mode: '1'
      )

      make_request({
        type: 'Spree::PaymentMethod::KlarnaCredit',
        preference_source: 'solidus_klarna_payments_env_credentials'
      })

      expect(SolidusKlarnaPayments::ValidateKlarnaCredentialsService)
        .to have_received(:call)
        .with(
          api_key: 'STATIC_API_KEY',
          api_secret: 'STATIC_API_SECRET',
          test_mode: '1',
          country: 'it'
        )
    end

    it 'does call the validate klarna creadentials service when the payment method type is klarna and is not using static preferences' do
      stub_validate_klarna_credentials_service

      make_request({
        type: 'Spree::PaymentMethod::KlarnaCredit',
        name: 'Test Klarna Method',
        preferred_country: 'us',
        preferred_api_key: 'API_KEY',
        preferred_api_secret: 'API_SECRET',
        preferred_test_mode: '0'
      })

      expect(SolidusKlarnaPayments::ValidateKlarnaCredentialsService)
        .to have_received(:call)
        .with(
          api_key: 'API_KEY',
          api_secret: 'API_SECRET',
          test_mode: '0',
          country: 'us'
        )
    end

    it 'does call the validate klarna creadentials service when the payment method type is klarna' do
      stub_validate_klarna_credentials_service

      make_request({
        type: 'Spree::PaymentMethod::KlarnaCredit'
      })

      expect(SolidusKlarnaPayments::ValidateKlarnaCredentialsService)
        .to have_received(:call)
    end

    it 'renders a success message when the validation returns true' do
      stub_validate_klarna_credentials_service.and_return(true)

      make_request({
        type: 'Spree::PaymentMethod::KlarnaCredit'
      })

      expect(flash[:notice]).to match(/configuration completed/)
      expect(flash[:success]).to match(/successfully updated/)
    end

    it 'renders the invalid credentials error when the validation returns false' do
      stub_validate_klarna_credentials_service.and_return(false)

      make_request({
        type: 'Spree::PaymentMethod::KlarnaCredit'
      })

      expect(flash[:error]).to match(/invalid/)
      expect(flash[:success]).to match(/successfully updated/)
    end

    it 'renders the cannot be tested error when the validation raises a missing credential exception' do
      stub_validate_klarna_credentials_service
        .and_raise(::SolidusKlarnaPayments::ValidateKlarnaCredentialsService::MissingCredentialsError)

      make_request({
        type: 'Spree::PaymentMethod::KlarnaCredit'
      })

      expect(flash[:error]).to match(/can not be tested/)
      expect(flash[:success]).to match(/successfully updated/)
    end
  end
end
