# frozen_string_literal: true

require 'test_helper'

class TestControllerTest < ActionDispatch::IntegrationTest
  test 'a flash notice appears if an invalid job type is sent' do
    post test_index_url, params: { job_type: 'fake_job_type' }

    assert flash.alert
    assert_redirected_to controller: :test, action: :index
  end

  test 'a job is enqueued and a notice is set' do
    FileIngestJob.expects(:perform_async)

    post test_index_url, params: { job_type: 'FileIngestJob' }

    assert flash.notice
  end

  test 'correct values for dropdowns exist' do
    get test_index_url

    assert_select "select[name='job_type']" do
      TestHelper::JOB_TYPES.each do |job_type|
        assert_select "option[value='#{job_type}']"
      end
    end

    assert_select "select[name='item_type']" do
      ItemType::TYPES.each do |item_type|
        assert_select "option[value='#{item_type}']"
      end
    end
  end
end
