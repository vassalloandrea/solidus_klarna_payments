# frozen_string_literal: true

module SolidusKlarnaPayments
  module Spree
    module Admin
      module PaymentMethodsControllerDecorator
        MODEL_NAME = 'Spree::PaymentMethod::KlarnaCredit'

        def update
          validate_api_credentials if klarna_payment_method?

          super
        end

        private

        def klarna_payment_method_params
          @klarna_payment_method_params ||= begin
            if using_static_preferences?
              ::Spree::Config
                .static_model_preferences
                .for_class(MODEL_NAME)
                .fetch(params['payment_method']['preference_source'])
                .preferences
            else
              params
                .require(:payment_method)
                .permit(
                  :preferred_api_key,
                  :preferred_api_secret,
                  :preferred_test_mode,
                  :preferred_country,
                  :preferred_tokenization
                )
            end
          end
        end

        def fetch_klarna_payment_method_param(key)
          if using_static_preferences?
            klarna_payment_method_params[key.to_sym]
          else
            klarna_payment_method_params["preferred_#{key}"]
          end
        end

        def klarna_payment_method?
          payment_method_params[:type] == MODEL_NAME
        end

        def validate_api_credentials
          result = ::SolidusKlarnaPayments::ValidateKlarnaCredentialsService.call(
            api_key: fetch_klarna_payment_method_param('api_key'),
            api_secret: fetch_klarna_payment_method_param('api_secret'),
            test_mode: fetch_klarna_payment_method_param('test_mode'),
            country: fetch_klarna_payment_method_param('country')
          )

          if result
            flash[:notice] = I18n.t('spree.klarna.valid_api_credentials')
          else
            flash[:error] = I18n.t('spree.klarna.invalid_api_credentials')
          end
        rescue ::SolidusKlarnaPayments::ValidateKlarnaCredentialsService::MissingCredentialsError
          flash[:error] = I18n.t('spree.klarna.can_not_test_api_connection')
        end

        def using_static_preferences?
          params.dig(:payment_method, :preference_source).present?
        end

        ::Spree::Admin::PaymentMethodsController.prepend self
      end
    end
  end
end
