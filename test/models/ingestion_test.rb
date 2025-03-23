# frozen_string_literal: true

require 'test_helper'

class IngestionTest < ActiveSupport::TestCase
  test 'file name is required' do
    assert_raises ActiveRecord::RecordInvalid do
      Ingestion.create!(file_name: nil)
    end
  end

  test 'ingested_at is set when ingest is completed' do
    ingestion = create(:ingestion)
    assert_nil ingestion.ingested_at
    ingestion.begin_ingest
    assert_nil ingestion.ingested_at
    ingestion.complete_ingest
    assert_not_nil ingestion.ingested_at
  end

  test 'ingestion state transitions work as expected' do
    ingestion = create(:ingestion)
    assert_equal ingestion.state, 'pending'
    ingestion.begin_ingest
    assert_equal ingestion.state, 'ingesting'
    ingestion.complete_ingest
    assert_equal ingestion.state, 'ingested'
  end

  test 'failed ingest state transitions work as expected' do
    create(:ingestion).tap do |ingestion|
      ingestion.fail_ingest
      assert_equal ingestion.state, 'ingestion_failed'
      assert_nil ingestion.ingested_at
    end

    create(:ingestion).tap do |ingestion|
      ingestion.begin_ingest
      ingestion.fail_ingest
      assert_equal ingestion.state, 'ingestion_failed'
      assert_nil ingestion.ingested_at
    end
  end
end
