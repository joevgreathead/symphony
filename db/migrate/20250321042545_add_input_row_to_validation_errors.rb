# frozen_string_literal: true

class AddInputRowToValidationErrors < ActiveRecord::Migration[7.1]
  def change
    add_column :validation_errors, :input_row, :jsonb
  end
end
