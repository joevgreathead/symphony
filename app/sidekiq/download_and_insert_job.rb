# frozen_string_literal: true

require 'aws-sdk-s3'

class DownloadAndInsertJob
  include Sidekiq::Job

  def perform(text_input)
    # Download a CSV and insert it into the database using minimal memory
    print_time_spent do
      print_memory_usage do
        puts 'Found the following buckets'
        Aws::S3::Resource.new.buckets.each do |bucket|
          puts "Bucket: #{bucket.name}"
        end
      end
    end
  rescue Aws::Errors::ServiceError => e
    puts "Couldn't list buckets; msg: #{e.message}"
  end

  # Via: https://dalibornasevic.com/posts/68-processing-large-csv-files-with-ruby
  def print_memory_usage
    memory_before = `ps -o rss= -p #{Process.pid}`.to_i
    yield
    memory_after = `ps -o rss= -p #{Process.pid}`.to_i

    puts "Memory: #{((memory_after - memory_before) / 1024.0).round(2)} MB"
  end

  # Via: https://dalibornasevic.com/posts/68-processing-large-csv-files-with-ruby
  def print_time_spent(&)
    time = Benchmark.realtime(&)

    puts "Time: #{time.round(2)}"
  end
end
