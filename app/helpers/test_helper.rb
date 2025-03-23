# frozen_string_literal: true

module TestHelper
  JOB_TYPES = [
    BucketListJob,
    CsvProcessingJob,
    FileIngestJob,
    TimeJob
  ].freeze

  def job_options
    JOB_TYPES.map { |value| [value.to_s, value.to_s] }
  end

  def item_type_options
    ItemType::TYPES.map { |type| [type.capitalize, type] }
  end

  def valid_type?(type)
    JOB_TYPES.any? { |job_type| job_type.to_s == type }
  end
end
