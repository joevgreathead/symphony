# frozen_string_literal: true

require 'get_process_mem'

class SideKiqJob
  include Sidekiq::Job

  def perform(*)
    if memory_profile?
      @memory = GetProcessMem.new
      GC.start(full_mark: true, immediate_sweep: true)
      @start_memory = @memory.mb
      @peak_memory = @memory.mb
    end

    run_job_steps(*)

    return unless memory_profile?

    Rails.logger.debug { "STRT MEMORY PROCESS USAGE: #{@start_memory}" }
    Rails.logger.debug { "PEAK MEMORY PROCESS USAGE: #{@peak_memory - @start_memory}" }
  end

  def checkpoint
    return unless memory_profile?

    GC.start(full_mark: true, immediate_sweep: true)
    current_memory = @memory.mb
    Rails.logger.debug { "CURRENT MEMORY USAGE: #{current_memory - @start_memory}MB" }
    @peak_memory = [@peak_memory, current_memory].max
  end

  def run_job_steps(*)
    start(*)
    run(*)
    complete(*)
  rescue StandardError => e
    error(e, *)

    raise
  end

  def memory_profile?
    false
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
end
