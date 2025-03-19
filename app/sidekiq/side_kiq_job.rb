# frozen_string_literal: true

class SideKiqJob
  include Sidekiq::Job

  def perform(*args)
    print_time_spent do
      print_memory_usage do
        start(*args)
        run(*args)
        complete(*args)
      rescue StandardError => e
        error(error, *args)

        raise
      end
    end
  end

  def start(*_)
    logger.debug 'Start step for job is not defined'
  end

  def run(*args)
    raise NotImplementedError
  end

  def error(_, *_)
    logger.debug 'Error step for job is not defined'
  end

  def complete(*_)
    logger.debug 'Complete step for job is not defined'
  end

  # Via: https://dalibornasevic.com/posts/68-processing-large-csv-files-with-ruby
  def print_memory_usage
    memory_before = `ps -o rss= -p #{Process.pid}`.to_i
    yield
    memory_after = `ps -o rss= -p #{Process.pid}`.to_i

    Rails.logger.debug { "Memory reported by SideKiqJob: #{((memory_after - memory_before) / 1024.0).round(2)} MB" }
  end

  # Via: https://dalibornasevic.com/posts/68-processing-large-csv-files-with-ruby
  def print_time_spent(&)
    time = Benchmark.realtime(&)

    Rails.logger.debug { "Time reported by SideKiqJob: #{time.round(2)}" }
  end
end
