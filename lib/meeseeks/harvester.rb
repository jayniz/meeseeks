# frozen_string_literal: true

require 'meeseeks/http_trap'

# Checks a queue in regular intervals and bulk submits measurements
# to a Circonus HTTPTrap https://login.circonus.com/resources/docs/user/Data/CheckTypes/HTTPTrap.html
module Meeseeks
  class Harvester
    attr_reader :interval, :max_batch_size, :cycle_count

    def initialize(queue:, http_trap:, interval: 60, max_batch_size: 100)
      @queue = queue
      @http_trap = http_trap
      @interval = interval
      @max_batch_size = max_batch_size
      @cycle_count = 0
      @lock = Mutex.new
    end

    def stats
      {
        cycle_count: @cycle_count,
        running: running?
      }
    end

    def start
      @continue = true
      return if @thread&.alive?

      @thread = Thread.new do
        loop do
          sleep(@interval)
          break unless @continue

          @cycle_count += 1
          drain
        end
      end
    end

    def stop
      @continue = false
    end

    def kill
      @thread&.kill if @thread&.alive?
    end

    def running?
      @thread&.alive?
    end

    def drain
      @lock.synchronize do
        drain_queue_async
      end
    end

    private

    def drain_queue_async
      loop do
        batch = batch_from_queue

        begin
          queue_size = @queue.size
          submit(batch, queue_size)
        rescue StandardError
          # TODO: think about whether or not this is a good idea. It's nice to
          # recover from the occasional HTTP hickup, but when we can't submit
          # to Circonus at all for whatever reason, we'll fill up the RAM. Do we
          # want to implement limited retries here, or do we want to impose a
          # max length on the queue, or what do we want to do?
          batch.map { |d| @queue.push(d) }
        end

        # Even if the batch is empty, we want to submit our own statistics
        # for this cycle, and that's why we don't break before the submit
        break if @queue.empty?
      end
    end

    def batch_from_queue
      batch = []

      loop do
        batch << @queue.pop(true)
        break if @queue.empty? || batch.length >= @max_batch_size - 1
      rescue ThreadError => e
        e.message == 'queue empty' ? break : raise
      end

      batch
    end

    def meeseeks_stats_payload(batch_size, queue_size)
      { meeseeks: {} }.tap do |stats|
        stats[:meeseeks].merge!(Payload.for('batch_size', batch_size))
        stats[:meeseeks].merge!(Payload.for('queue_size', queue_size))
        stats[:meeseeks].merge!(Payload.for('submit_count', submit_count))
        stats[:meeseeks].merge!(Payload.for('cycle_count', @cycle_count))
      end
    end

    def submit_count
      @http_trap.submit_count
    end

    def submit(measurements, queue_size)
      stats = [meeseeks_stats_payload(measurements.length, queue_size)]
      @http_trap.submit(measurements + stats)
    end
  end
end
