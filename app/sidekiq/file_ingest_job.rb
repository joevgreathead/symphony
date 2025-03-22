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

  BATCH_SIZE = 1_000
  DEFAULT_VALIDATION = ->(row, field) { valid_field?(row, field) }
  FIELD_DEFAULT = { validator: DEFAULT_VALIDATION }.freeze
  FIELDS = [
    {
      field: :first,
      message: 'First name can\'t be blank'
    },
    {
      field: :last,
      message: 'Last name can\'t be blank'
    },
    {
      field: :email,
      message: 'Email can\'t be blank'
    },
    {
      field: :email,
      validator: ->(row, field) { field_value(row, field).blank? || field_value(row, field).include?('@') },
      message: 'Email must be in valid format'
    },
    {
      field: :phone,
      message: 'Phone can\'t be blank'
    }

  ].freeze

  def start(s3_object_key)
    @ingestion = Ingestion.create!(file_name: s3_object_key)
    @item_type = ValidationError::ITEM_TYPES.sample
    @error_rows = []
    @error_row_count = 0
    checkpoint
  end

  def error(_, _)
    @ingestion&.fail_ingest
  end

  def complete(*_)
    process_error_rows
    @ingestion.update(state: :ingested, rows: @line_count)

    # TODO: Export streamed data from temp table to permanent table and apply normalization

    logger.info "Found #{@error_row_count} rows with errors"
    checkpoint
  end

  def process_row(row)
    valid, error_fields = self.class.valid? row

    if valid
      logger.info 'Valid: true'
      # TODO: List of tasks
      # - Create a temp table
      # - Stream in valid row
      #
    else
      logger.info "Errors: #{error_fields.join(', ')}"
      @error_rows << { row:, error_fields: }
      @error_row_count += 1
    end
  end

  def post_process_row(_)
    process_error_rows if (@error_row_count % BATCH_SIZE).zero?

    checkpoint if (rand(1..500) % 500).zero?
  end

  def process_error_rows
    return if @error_rows.empty?

    checkpoint

    logger.info "Found another #{@error_rows.size} error rows"

    rows = @error_rows.each_with_object([]) do |error_row, insertable_rows|
      error_fields, row = error_row.values_at(:error_fields, :row)

      error_fields.each do |field|
        error_field, error_message = field.values_at(0, 1, 2)

        insertable_rows << {
          item_type: @item_type,
          error_field:,
          error_message:,
          ingestion_id: @ingestion.id,
          input_row: row.to_h
        }
      end
    end

    ValidationError.insert_all!(rows) # rubocop:disable Rails/SkipsModelValidations

    @error_rows = []
  end

  class << self
    def valid?(row)
      error_fields = FIELDS.reject do |field_hash|
        field, validator = FIELD_DEFAULT.merge(field_hash).values_at(:field, :validator)

        validator.call(row, field)
      end

      Rails.logger.info row.to_h

      [error_fields.empty?, error_fields.map { |field| field.values_at(:field, :message) }, row.to_h]
    end

    def field_value(row, field_sym)
      row[row.headers[STATIC_CONFIG[field_sym] - 1]]
    end

    def valid_field?(row, field_sym)
      field_value(row, field_sym).present?
    end
  end
end
