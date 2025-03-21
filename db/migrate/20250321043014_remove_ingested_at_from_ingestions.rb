# frozen_string_literal: true

class RemoveIngestedAtFromIngestions < ActiveRecord::Migration[7.1]
  def up
    remove_column :ingestions, :ingested_at
  end

  def down
    add_column :ingestions, :ingested_at, :timestamp
  end
end
