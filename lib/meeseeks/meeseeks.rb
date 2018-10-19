# frozen_string_literal: true

require 'meeseeks/error'
require 'meeseeks/harvester'
require 'meeseeks/http_trap'
require 'meeseeks/payload'
require 'date'

# Allows you to asynchronously send measurements to Circonus. Measurements are
# stored in a queue and a harvester in a background thread empties the queue
# in regular intervals and submits data to a Circonus HTTPTrap.
module Meeseeks
  class Meeseeks
    attr_reader :queue, :harvester, :http_trap

    def initialize(data_submission_url: nil,
                   interval: nil,
                   max_batch_size: nil,
                   max_queue_size: nil)
      @queue = Queue.new
      @interval = interval || ENV.fetch('MEESEEKS_INTERVAL', 60).to_i
      @max_queue_size = max_queue_size ||
                        ENV.fetch('MEESEEKS_MAX_QUEUE_SIZE', 100).to_i
      @max_batch_size = max_batch_size ||
                        ENV.fetch('MEESEEKS_MAX_BATCH_SIZE', 1_000).to_i
      @data_submission_url = data_submission_url ||
                             ENV.fetch('MEESEEKS_DATA_SUBMISSION_URL')

      create_http_trap
      start_harvester
    end

    def record!(group, metric, value, time = DateTime.now)
      Payload.validate_type!(value)
      return false if @queue.size >= @max_queue_size

      @queue.push(Payload.for_group(group, metric, value, time))
      true
    end

    def record(group, metric, value, time = DateTime.now)
      record!(group, metric, value, time)
    rescue Error
      false
    end

    private

    def create_http_trap
      @http_trap = HTTPTrap.new(@data_submission_url)
    end

    def start_harvester
      @harvester = Harvester.new(
        queue: @queue,
        http_trap: @http_trap,
        interval: @interval,
        max_batch_size: @max_batch_size
      )
      @harvester.start
    end
  end
end
