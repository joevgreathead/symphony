# frozen_string_literal: true

require 'csv'
require 'fileutils'

namespace :sample do
  desc 'Generate a sample CSV file with X number of rows'
  task csv: :environment do
    FileUtils.mkdir_p 'data'
    CSV.open('data/sample_file.csv', 'w') do |csv|
      csv << ['First name', 'Last name', 'Email', 'Phone', 'Id']
      25_000.times do |time|
        csv << [
          risk(20, "Joe ##{time}"),
          risk(20, 'Smith'),
          risk(20, "joe.smith#{time}#{risk(20, '@')}example.com"),
          risk(20, "123#{time.to_s.rjust(7, '0')}"),
          time.to_s.rjust(42, '0')
        ]
      end
    end
  end

  def risk(percent, default)
    rand(1..10) < (percent / 10) ? nil : default
  end
end
