# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 20_250_328_040_840) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'ingestions', force: :cascade do |t|
    t.string 'file_name'
    t.integer 'rows', default: 0, null: false
    t.datetime 'ingested_at', precision: nil
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'state'
    t.index ['id'], name: 'index_ingestions_on_id'
  end

  create_table 'people', force: :cascade do |t|
    t.string 'first'
    t.string 'last'
    t.string 'email'
    t.string 'phone'
    t.string 'unique_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'users', force: :cascade do |t|
    t.string 'first_name'
    t.string 'last_name'
    t.string 'email'
    t.string 'phone_number'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'validation_errors', force: :cascade do |t|
    t.string 'item_type'
    t.string 'error_field'
    t.text 'error_message'
    t.integer 'ingestion_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.jsonb 'input_row'
    t.index %w[item_type error_field], name: 'index_validation_errors_on_item_type_and_error_field'
  end
end
