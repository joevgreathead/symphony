# frozen_string_literal: true

class Person < ApplicationRecord
  validates :first, presence: true
  validates :last, presence: true
  validates :email, presence: true
  validates :phone, presence: true

  TEMP_TABLE_COLUMNS = %i[first last email phone].freeze
end
