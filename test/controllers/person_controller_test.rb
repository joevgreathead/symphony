# frozen_string_literal: true

require 'test_helper'

class PersonControllerTest < ActionDispatch::IntegrationTest
  test 'index responds successfully' do
    get people_url

    assert_equal '200', response.code
  end
end
