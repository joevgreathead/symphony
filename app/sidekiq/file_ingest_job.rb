# frozen_string_literal: true

require 'aws-sdk-s3'
require 'csv'

class FileIngestJob < CsvProcessingJob
  STATIC_CONFIG = {
    first: 1,
    last: 2,
    email: 3,
    phone: 4
  }.freeze

  FIELDS = %i[first last email phone].freeze

  def start(s3_object_key)
    @ingestion = Ingestion.create(file_name: s3_object_key)
    @error_rows = []
    @error_row_count = 0
  end

  def error(_, _)
    @ingestion.fail_ingest
  end

  def complete(*_)
    @ingestion.update(state: :ingested, rows: @line_count)

    logger.info "Found #{@error_row_count} rows with errors"
  end

  def process_row(row)
    valid, error_fields = valid? row

    if valid
      logger.info 'Valid: true'
    else
      logger.info "Errors: #{error_fields.join(', ')}"
      @error_rows << { row:, error_fields: }
      @error_row_count += 1

      @error_rows = [] if (@error_row_count % 500).zero?
    end
  end

  def valid?(row)
    error_fields = FIELDS.reject { |field| valid_field?(row, field) }

    [error_fields.empty?, error_fields]
  end

  def valid_field?(row, field_sym)
    row[row.headers[STATIC_CONFIG[field_sym]]].present?
  end
end
