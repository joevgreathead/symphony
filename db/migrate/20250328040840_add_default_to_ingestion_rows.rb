# frozen_string_literal: true

class AddDefaultToIngestionRows < ActiveRecord::Migration[7.1]
  def up
    change_column :ingestions, :rows, :integer, default: 0, null: false
  end

  def down
    change_column :ingestions, :rows, :integer, default: nil, null: true
  end
end
