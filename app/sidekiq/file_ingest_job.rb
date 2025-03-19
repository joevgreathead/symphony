# frozen_string_literal: true

require 'aws-sdk-s3'
require 'csv'

class FileIngestJob < CsvProcessingJob
  def process_row(row)
    logger.info row
  end
end
