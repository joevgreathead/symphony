# frozen_stirng_literal: true

require 'test_helper'

class FileIngestJobTest < ActiveSupport::TestCase
  def setup
    @bucket = 'bucket_name'
    @object_key = 'test.csv'
    @item_type = ItemType::TYPES.sample
    @mock_s3_client = mock
    Aws::S3::Client.stubs(:new).returns(@mock_s3_client)
  end

  test 'no validation errors are created with valid person row' do
    csv_data = "First,Last,Email,Phone\nJohn,Smith,js@js.com,123-456-7890"
    @mock_s3_client.expects(:get_object).multiple_yields(csv_data)

    assert_no_changes -> { ValidationError.count } do
      FileIngestJob.new.perform(@object_key, ItemType::PERSON)
    end
  end

  test 'no validation errors are created with valid person rows' do
    csv_data = "First,Last,Email,Phone\nJohn,Smith,js@js.com,123-456-7890\nJane,Doe,jd@jd.com,098-765-4321"
    @mock_s3_client.expects(:get_object).multiple_yields(csv_data)

    assert_no_changes -> { ValidationError.count } do
      FileIngestJob.new.perform(@object_key, ItemType::PERSON)
    end
  end

  test 'validation errors are created for standard fields missing on one row' do
    csv_data = "First,Last,Email,Phone\n,,js@js.com,123-456-7890"
    @mock_s3_client.expects(:get_object).multiple_yields(csv_data)

    assert_changes -> { ValidationError.count }, from: 0, to: 2 do
      FileIngestJob.new.perform(@object_key, ItemType::PERSON)
    end
  end

  test 'validation errors are created for standard fields missing on multiple rows' do
    csv_data = "First,Last,Email,Phone\n,,js@js.com,123-456-7890\nJane,Doe,,"
    @mock_s3_client.expects(:get_object).multiple_yields(csv_data)

    assert_changes -> { ValidationError.count }, from: 0, to: 4 do
      FileIngestJob.new.perform(@object_key, ItemType::PERSON)
    end
  end
end
