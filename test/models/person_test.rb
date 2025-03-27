# frozen_string_literal: true

require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  test 'first can\'t be blank' do
    assert_raises ActiveRecord::RecordInvalid, match: 'First can\'t be blank' do
      create(:person, first: nil)
    end
  end

  test 'last can\'t be blank' do
    assert_raises ActiveRecord::RecordInvalid, match: 'Last can\'t be blank' do
      create(:person, last: nil)
    end
  end

  test 'email can\'t be blank' do
    assert_raises ActiveRecord::RecordInvalid, match: 'Email can\'t be blank' do
      create(:person, email: nil)
    end
  end

  test 'phone can\'t be blank' do
    assert_raises ActiveRecord::RecordInvalid, match: 'Phone can\'t be blank' do
      create(:person, phone: nil)
    end
  end
end
