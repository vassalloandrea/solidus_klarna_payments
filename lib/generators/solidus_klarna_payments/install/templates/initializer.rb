# frozen_string_literal: true

SolidusKlarnaPayments.configure do |config|
  # config.confirmation_url = ->(_store, _order) { "http://example.com/thank-you" }
  # config.image_host = ->(_line_item) { "http://images.example.com" }
  # config.product_url = ->(line_item) { "http://example.com/product/#{line_item.variant.id}" }

  # config.store_customer_token_service_class = 'SolidusKlarnaPayments::StoreCustomerTokenService'
  # config.retrieve_customer_token_service_class = 'SolidusKlarnaPayments::RetrieveCustomerTokenService'
end

if ENV.fetch('SOLIDUS_KLARNA_PAYMENTS_API_KEY', nil)
  Spree::Config.static_model_preferences.add(
    'Spree::PaymentMethod::KlarnaCredit',
    'solidus_klarna_payments_env_credentials',
    api_key: ENV.fetch('SOLIDUS_KLARNA_PAYMENTS_API_KEY'), # username in the docs
    api_secret: ENV.fetch('SOLIDUS_KLARNA_PAYMENTS_API_SECRET'), # password in the docs
    test_mode: !Rails.env.production?,
    tokenization: ENV.fetch('SOLIDUS_KLARNA_PAYMENTS_TOKENIZATION', false),
    country: ENV.fetch('SOLIDUS_KLARNA_PAYMENTS_COUNTRY', 'us'),
    payment_method: '', # one of invoice, pix, base_account, deferred_interest, fixed_amount
    design: '',
    color_details: '',
    color_button: '',
    color_button_text: '',
    color_checkbox: '',
    color_checkbox_checkmark: '',
    color_header: '',
    color_link: '',
    color_border: '',
    color_border_selected: '',
    color_text: '',
    color_text_secondary: '',
    radius_border: ''
  )
end
