# frozen_string_literal: true

require 'aws-sdk-s3'

class BucketListJob < SideKiqJob
  def run(arg)
    # Download a CSV and insert it into the database using minimal memory
    Rails.logger.info 'Found the following buckets'
    Aws::S3::Resource.new.buckets.each do |bucket|
      Rails.logger.info "Bucket: #{bucket.name}"
    end
  rescue Aws::Errors::ServiceError => e
    Rails.logger.info "Couldn't list buckets; msg: #{e.message}"
  end
end
