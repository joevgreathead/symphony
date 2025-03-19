# frozen_string_literal: true

class ValidationError < ApplicationRecord
  belongs_to :ingestion

  ITEM_TYPES = %w[person place thing].freeze

  validates :error_field, presence: true
  validates :error_message, presence: true
  validates :item_type, presence: true, inclusion: ITEM_TYPES
end
