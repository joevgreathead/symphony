# frozen_string_literal: true

class CreateValidationErrors < ActiveRecord::Migration[7.1]
  def change
    create_table :validation_errors do |t|
      t.string :item_type
      t.string :error_field
      t.text :error_message
      t.integer :ingestion_id

      t.index %i[item_type error_field]

      t.timestamps
    end
  end
end
