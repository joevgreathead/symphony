# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'first name is present' do
    user = build(:user, first_name: nil)

    assert_raises ActiveRecord::RecordInvalid, match: "First name can't be blank" do
      user.save!
    end
  end

  test 'last name is present' do
    user = build(:user, last_name: nil)

    assert_raises ActiveRecord::RecordInvalid, match: "Last name can't be blank" do
      user.save!
    end
  end

  test 'email is present' do
    user = build(:user, email: nil)

    assert_raises ActiveRecord::RecordInvalid, match: "Email can't be blank" do
      user.save!
    end
  end
end
