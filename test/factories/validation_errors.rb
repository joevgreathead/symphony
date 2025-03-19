# frozen_string_literal: true

FactoryBot.define do
  factory :validation_error do
    item_type { %w[person place thing].sample }
    error_field { 'first_name' }
    error_message { 'MyText' }
    ingestion { create(:ingestion) }
  end
end
