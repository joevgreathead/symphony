# frozen_string_literal: true

require 'test_helper'
class FileIngestJobTest < Minitest::Test
  def setup
    @bucket = 'bucket_name'
    @object_key = 'test.csv'

    @mock_s3_client = mock
    Aws::S3::Client.stubs(:new).returns(@mock_s3_client)
  end

  def test_process_correct_number_of_rows
    csv_data = "First,Last,Email,Phone\nJohn,Smith,js@js.com,123-456-7890\nJane,Doe,jd@jd.com,098-765-4321"
    @mock_s3_client.expects(:get_object).multiple_yields(csv_data)
    @job = FileIngestJob.new

    @job.expects(:process_row).times(2)

    @job.perform(@object_key)
  end

  def test_load_works_across_chunks
    csv_chunks = [
      "First,Last,Email,Phone\nJo",
      'hn,Smith,js@js.com,123-4',
      "56-7890\nJane,Doe,jd@jd.com",
      ',098-765-4321'
    ]
    @mock_s3_client.expects(:get_object).multiple_yields(csv_chunks.first, csv_chunks.second, csv_chunks.third,
                                                         csv_chunks.fourth)
    @job = FileIngestJob.new

    @job.expects(:process_row).times(2)

    @job.perform(@object_key)
  end
end
