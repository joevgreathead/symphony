# frozen_string_literal: true

class CreateIngestions < ActiveRecord::Migration[7.1]
  def change
    create_table :ingestions do |t|
      t.string :file_name
      t.integer :rows
      t.timestamp :ingested_at

      t.index :id

      t.timestamps
    end
  end
end
