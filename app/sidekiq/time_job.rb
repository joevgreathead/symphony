# frozen_string_literal: true

class TimeJob
  include Sidekiq::Job

  def perform(message)
    puts "At the tone, the time will be #{Time.zone.now.strftime('%I:%M %P')}"
    puts "Also, a message for you: #{message}"
  end
end
