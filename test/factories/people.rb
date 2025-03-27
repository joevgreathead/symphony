# frozen_string_literal: true

FactoryBot.define do
  factory :person do
    first { 'MyString' }
    last { 'MyString' }
    email { 'MyString' }
    phone { 'MyString' }
    unique_id { 'MyString' }
  end
end
