# frozen_string_literal: true

require 'test_helper'

class ValidationErrorTest < ActiveSupport::TestCase
  test 'error_field is required' do
    assert_raises ActiveRecord::RecordInvalid, match: "Error field can't be blank" do
      error = build(:validation_error, error_field: nil)
      error.save!
    end
  end

  test 'error_message is required' do
    assert_raises ActiveRecord::RecordInvalid, match: "Error message can't be blank" do
      error = build(:validation_error, error_message: nil)
      error.save!
    end
  end

  test 'item_type is required' do
    assert_raises ActiveRecord::RecordInvalid, match: "Item type can't be blank" do
      error = build(:validation_error, item_type: nil)
      error.save!
    end
  end

  test 'item_type value is checked for inclusion' do
    assert_raises ActiveRecord::RecordInvalid, match: 'Item type is not included in the list' do
      error = build(:validation_error, item_type: 'Test')
      error.save!
    end
  end
end
