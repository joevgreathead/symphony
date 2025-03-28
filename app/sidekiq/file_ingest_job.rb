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

  def start(s3_object_key, item_type)
    @ingestion = Ingestion.create!(file_name: s3_object_key)
    @item_type = item_type

    raise ArgumentError, 'Invalid item type' if ItemType::TYPES.exclude? @item_type
    raise ArgumentError, 'Unsupported item type' if ItemType::VALIDATIONS[@item_type].blank?

    @error_rows = []
    @error_row_count = 0

    @valid_rows = []
    @valid_row_count = 0

    @copy_running = false

    @item_columns = Person::TEMP_TABLE_COLUMNS
    temp_table_columns = @item_columns.map { |col| "\"#{col}\" varchar not null" }.join(",\n")
    @temp_table_name = "temp_#{@item_type}_#{@ingestion.id}"
    @connection = ActiveRecord::Base.connection.raw_connection

    @connection.exec("create temporary table #{@temp_table_name} (\n#{temp_table_columns}\n)")

    checkpoint
    @ingestion.begin_ingest!
  end

  def error(_, *_)
    @ingestion.fail_ingest!
    close_connection
  end

  def complete(*_)
    process_error_rows
    process_valid_rows

    if @valid_row_count.positive?
      @connection.exec(
        <<~SQL.squish
          insert into #{@item_type.pluralize} (#{column_names}, created_at, updated_at)
          select distinct #{column_names}, now(), now() from #{@temp_table_name}
        SQL
      )
    end

    @ingestion.complete_ingest!
    @ingestion.update!(rows: @line_count)
    close_connection

    # TODO: Export streamed data from temp table to permanent table and apply normalization

    logger.info '++++'
    logger.info "Ingestion id: #{@ingestion.id}"
    logger.info "Found #{@error_row_count} rows with errors"
    logger.info "Found #{@valid_row_count} rows that were valid"
    logger.info '++++'
    checkpoint
  end

  def close_connection
    @connection&.put_copy_end if @copy_running
  rescue PG::Error => e
    Rails.logger.error(e)
  end

  def process_row(row)
    valid, error_fields = valid? row, @item_type

    if valid
      logger.info 'Valid: true'

      @valid_rows << row
      @valid_row_count += 1
    else
      logger.info "Errors: #{error_fields.join(', ')}"
      @error_rows << { row:, error_fields: }
      @error_row_count += 1
    end
  end

  def post_process_row(_)
    process_error_rows if (@error_row_count % BATCH_SIZE).zero?
    process_valid_rows if (@valid_row_count % BATCH_SIZE).zero?

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

  def column_names
    @item_columns.map { |col| "\"#{col}\"" }.join(', ')
  end

  def process_valid_rows
    return if @valid_rows.empty?

    logger.info "Found another #{@valid_rows.size} valid rows"

    @connection.exec("copy #{@temp_table_name} (#{column_names}) from stdin csv")
    @copy_running = true
    @valid_rows.each do |valid_row|
      row_data = @item_columns.map { |column| field_value(valid_row, column) }.map { |field| "\"#{field}\"" }.join(',')
      @connection.put_copy_data("#{row_data}\n")
    end
    @connection.put_copy_end
    @copy_running = false

    @valid_rows = []
  end

  def valid?(row, item_type)
    error_fields = ItemType.validate(->(field) { field_value(row, field) }, item_type)

    [error_fields.empty?, error_fields.map { |field| field.values_at(:field, :message) }]
  end

  def field_value(row, field_sym)
    row[row.headers[STATIC_CONFIG[field_sym] - 1]]
  end
end
