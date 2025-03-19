# frozen_string_literal: true

require 'aws-sdk-s3'
require 'csv'

class CsvProcessingJob < SideKiqJob
  def run(s3_object_key)
    # Download a CSV and insert it into the database using minimal memory
    s3_client = Aws::S3::Client.new
    file_key = s3_object_key.presence || 'symphony/data/imports/test-dates-y2025.csv'

    @buffer = ''
    @header = []
    @line_count = 0

    s3_client.get_object(
      bucket: Symphony::Application.config.s3_bucket,
      key: file_key
    ) do |file_chunk|
      process_chunk(file_chunk)
    end

    call_process_with_row(@buffer)

    logger.debug "Job processed a file @ key='{file_key}' rows=#{@line_count}"
  rescue Aws::Errors::ServiceError => e
    logger.error "Couldn't access file for some reason; msg: #{e.message}"
  end

  def process_chunk(file_chunk)
    @buffer += file_chunk

    while (newline_index = @buffer.index("\n"))
      row_str = @buffer[0..newline_index]
      @buffer = @buffer[(newline_index + 1)..] || ''

      if @header.empty?
        @header = CSV.parse_line(row_str)
        next
      end

      call_process_with_row(row_str)
    end
  end

  def call_process_with_row(row_str)
    return if row_str.empty?

    row = CSV::Row.new(@header, CSV.parse_line(row_str))

    @line_count += 1

    process_row(row)
  end

  def process_row(row)
    raise NotImplementedError
  end
end
