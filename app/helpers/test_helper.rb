# frozen_string_literal: true

module TestHelper
  JOB_TYPES = [
    BucketListJob,
    CsvProcessingJob,
    FileIngestJob,
    TimeJob
  ].freeze

  def job_options
    JOB_TYPES.map do |value|
      [value.to_s, value.to_s]
    end
  end

  def valid_type?(type)
    result = JOB_TYPES.any? { |job_type| job_type.to_s == type }
    puts "Looking for [#{type}] Result: #{result}"

    result
  end
end
