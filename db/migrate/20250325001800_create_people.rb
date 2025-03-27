# frozen_string_literal: true

class CreatePeople < ActiveRecord::Migration[7.1]
  def change
    create_table :people do |t|
      t.string :first
      t.string :last
      t.string :email
      t.string :phone
      t.string :unique_id

      t.index %i[first last email phone], unique: true

      t.timestamps
    end
  end
end
