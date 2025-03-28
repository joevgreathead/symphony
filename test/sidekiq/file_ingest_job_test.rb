# frozen_string_literal: true

require 'test_helper'
require 'mock_connection'

class FileIngestJobTest < ActiveSupport::TestCase
  def setup
    @bucket = 'bucket_name'
    @object_key = 'test.csv'
    @item_type = ItemType::TYPES.sample
    @mock_s3_client = mock
    Aws::S3::Client.stubs(:new).returns(@mock_s3_client)
    @mock_connection = MockConnection.new
    ActiveRecord::Base.connection.stubs(:raw_connection).returns @mock_connection
  end

  test 'no validation errors are created with valid person row' do
    csv_data = "First,Last,Email,Phone\nJohn,Smith,js@js.com,123-456-7890"
    @mock_s3_client.expects(:get_object).multiple_yields(csv_data)

    assert_no_changes -> { ValidationError.count } do
      FileIngestJob.new.perform(@object_key, ItemType::PERSON)
    end
    assert_equal :ingested, Ingestion.first.state.to_sym
  end

  test 'no validation errors are created with valid person rows' do
    csv_data = "First,Last,Email,Phone\nJohn,Smith,js@js.com,123-456-7890\nJane,Doe,jd@jd.com,098-765-4321"
    @mock_s3_client.expects(:get_object).multiple_yields(csv_data)

    assert_no_changes -> { ValidationError.count } do
      FileIngestJob.new.perform(@object_key, ItemType::PERSON)
    end
    assert_equal :ingested, Ingestion.first.state.to_sym
  end

  test 'validation errors are created for standard fields missing on one row' do
    csv_data = "First,Last,Email,Phone\n,,js@js.com,123-456-7890"
    @mock_s3_client.expects(:get_object).multiple_yields(csv_data)

    assert_changes -> { ValidationError.count }, from: 0, to: 2 do
      FileIngestJob.new.perform(@object_key, ItemType::PERSON)
    end
    assert_equal :ingested, Ingestion.first.state.to_sym
  end

  test 'validation errors are created for standard fields missing on multiple rows' do
    csv_data = "First,Last,Email,Phone\n,,js@js.com,123-456-7890\nJane,Doe,,"
    @mock_s3_client.expects(:get_object).multiple_yields(csv_data)

    assert_changes -> { ValidationError.count }, from: 0, to: 4 do
      FileIngestJob.new.perform(@object_key, ItemType::PERSON)
    end
    assert_equal :ingested, Ingestion.first.state.to_sym
  end

  test 'valid rows are streamed to the database with correct columns' do
    Ingestion.any_instance.stubs(:id).returns(666)
    expected = [
      "\"John\",\"Smith\",\"js@js.com\",\"123-456-7890\"\n",
      "\"Jane\",\"Doe\",\"jd@jd.com\",\"098-765-4321\"\n"
    ]
    expected_execution = 'copy temp_person_666 ("first", "last", "email", "phone") from stdin csv'
    csv_data = "First,Last,Email,Phone\nJohn,Smith,js@js.com,123-456-7890\nJane,Doe,jd@jd.com,098-765-4321"
    @mock_s3_client.expects(:get_object).multiple_yields(csv_data)

    FileIngestJob.new.perform(@object_key, ItemType::PERSON)

    assert_equal expected_execution, @mock_connection.executions[-2]
    expected.each_with_index do |expected_row, index|
      assert_equal expected_row, @mock_connection.put_data[index]
    end
    assert_equal :ingested, Ingestion.first.state.to_sym
  end

  test 'connection is closed even in an error scenario' do
    error_text = 'Some connection error'
    csv_data = "First,Last,Email,Phone\nJohn,Smith,js@js.com,123-456-7890"
    @mock_s3_client.expects(:get_object).multiple_yields(csv_data)
    @mock_connection.expects(:put_copy_data).raises(StandardError.new(error_text))

    assert_raises StandardError, match: error_text do
      FileIngestJob.new.perform(@object_key, ItemType::PERSON)
    end

    assert @mock_connection.end_called
    assert_equal :ingestion_failed, Ingestion.first.state.to_sym
  end

  test 'job creates a temp table with the relevant item\'s columns' do
    Ingestion.any_instance.stubs(:id).returns(666)
    expected_create = "create temporary table temp_person_666 (\n" \
                      "\"first\" varchar not null,\n" \
                      "\"last\" varchar not null,\n" \
                      "\"email\" varchar not null,\n" \
                      "\"phone\" varchar not null\n" \
                      ')'
    csv_data = "First,Last,Email,Phone\nJohn,Smith,js@js.com,123-456-7890"
    @mock_s3_client.expects(:get_object).multiple_yields(csv_data)

    FileIngestJob.new.perform(@object_key, ItemType::PERSON)

    assert_equal expected_create, @mock_connection.executions.first
    assert_equal :ingested, Ingestion.first.state.to_sym
  end

  test 'one insert to item table is run if a valid row is found' do
    csv_data = "First,Last,Email,Phone\nJohn,Smith,js@js.com,123-456-7890"
    @mock_s3_client.expects(:get_object).multiple_yields(csv_data)

    FileIngestJob.new.perform(@object_key, ItemType::PERSON)

    assert(@mock_connection.executions.one? { |exec| exec.downcase.starts_with? 'insert into' })
    assert_equal :ingested, Ingestion.first.state.to_sym
  end

  test 'no insert to item table is run if no valid rows are found' do
    csv_data = "First,Last,Email,Phone\n,Smith,js@js.com,123-456-7890"
    @mock_s3_client.expects(:get_object).multiple_yields(csv_data)

    FileIngestJob.new.perform(@object_key, ItemType::PERSON)

    assert(@mock_connection.executions.none? { |exec| exec.downcase.starts_with? 'insert into' })
    assert_equal :ingested, Ingestion.first.state.to_sym
  end
end
