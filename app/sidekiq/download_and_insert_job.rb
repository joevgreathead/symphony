# frozen_string_literal: true

require 'aws-sdk-s3'

class DownloadAndInsertJob
  include Sidekiq::Job

  def perform(text_input)
    # Download a CSV and insert it into the database using minimal memory
    puts 'Found the following buckets'
    Aws::S3::Resource.new.buckets.each do |bucket|
      puts "Bucket: #{bucket.name}"
    end
  rescue Aws::Errors::ServiceError => e
    puts "Couldn't list buckets; msg: #{e.message}"
  end
end
