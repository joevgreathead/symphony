# frozen_string_literal: true

class AddStateToIngestions < ActiveRecord::Migration[7.1]
  def change
    add_column :ingestions, :state, :string
  end
end
