# frozen_string_literal: true

require 'test_helper'

class SideKiqJobTest < ActiveSupport::TestCase
  class TestJob < SideKiqJob
    def run(*_); end
  end

  class TestJobWithProfiling < SideKiqJob
    def run(*_); end

    def memory_profile?
      true
    end
  end

  test 'job steps are run and passed all parameters' do
    parameters = %w[a b c]

    job = TestJob.new

    job.expects(:start).with(*parameters)
    job.expects(:run).with(*parameters)
    job.expects(:complete).with(*parameters)

    job.perform(*parameters)
  end

  test 'error callback is used when a step raises an error' do
    job = TestJob.new
    error_message = 'An error occurred!'

    job.expects(:run).raises(StandardError.new(error_message))
    job.expects(:error)
    Rails.logger.expects(:error)

    assert_raises StandardError, match: error_message do
      job.perform
    end
  end

  test 'memory profiling is turned off by default' do
    job = TestJob.new

    assert_not job.memory_profile?
  end

  test 'calling checkpoint without turning on profiling does nothing' do
    job = TestJob.new

    GC.expects(:start).never
    Rails.logger.expects(:debug).never

    assert_nil job.checkpoint
  end

  test 'turning on memory profiling works as expected' do
    job = TestJobWithProfiling.new

    GC.expects(:start)
    Rails.logger.expects(:debug).twice

    job.perform
  end
end
