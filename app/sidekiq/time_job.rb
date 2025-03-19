# frozen_string_literal: true

class TimeJob < SideKiqJob
  def run(message)
    Rails.logger.info "At the tone, the time will be #{Time.zone.now.strftime('%I:%M %P')}"
    Rails.logger.info "Also, a message for you: #{message}" if message.present?
  end
end
