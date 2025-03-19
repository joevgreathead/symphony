# frozen_string_literal: true

require 'aws-sdk-s3'
require 'csv'

class FileIngestJob < CsvProcessingJob
  def start(s3_object_key)
    @ingestion = Ingestion.create(file_name: s3_object_key)
  end

  def process_row(row)
    logger.info row
  end

  def error(_, _)
    @ingestion.fail_ingest
  end

  def complete(*_)
    @ingestion.update(state: :ingested, rows: @line_count)
  end
end
