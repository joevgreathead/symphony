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
end
