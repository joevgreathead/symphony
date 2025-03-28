# frozen_string_literal: true

require 'test_helper'

class IngestionsControllerTest < ActionDispatch::IntegrationTest
  test 'index shows row data for all ingestions' do
    create_list(:ingestion, 2)

    get ingestions_url

    assert_select 'div.ingestion' do |elements|
      assert_equal 2, elements.size
    end
  end

  test 'pagy presents the right page count' do
    create_list(:ingestion, 35)

    get ingestions_url

    assert_select 'nav.pagy' do
      assert_select 'a[href="/ingestions?page=2"]'
      assert_select 'a[href="/ingestions?page=3"]'
    end
  end
end
