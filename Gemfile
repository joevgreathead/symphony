# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.7'

gem 'aasm', '~> 5.5'
gem 'after_commit_everywhere', '~> 1.6'
gem 'aws-sdk-s3', '~> 1.182'
gem 'bootsnap', require: false
gem 'cssbundling-rails'
gem 'csv', '~> 3.3'
gem 'jbuilder'
gem 'jsbundling-rails'
gem 'pg', '~> 1.1'
gem 'propshaft'
gem 'puma', '>= 5.0'
gem 'rails', '~> 7.1.5', '>= 7.1.5.1'
gem 'sidekiq', '~> 8.0'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[windows jruby]

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows]
  gem 'dotenv'
  gem 'factory_bot'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'get_process_mem', '~> 1.0'
  gem 'pry'
end

group :development do
  gem 'benchmark', '~> 0.4.0'
  gem 'rack-mini-profiler'
  gem 'rubocop', '~> 1.73', require: false
  gem 'rubocop-rails', require: false
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'mocha', '~> 2.7'
  gem 'selenium-webdriver'
end
