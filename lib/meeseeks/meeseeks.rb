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

    def initialize(data_submission_url:,
                   interval: 60,
                   max_batch_size: 100,
                   max_queue_size: 10_000)
      @queue = Queue.new
      @max_queue_size = max_queue_size
      @http_trap = HTTPTrap.new(data_submission_url)
      @harvester = Harvester.new(
        queue: @queue,
        http_trap: @http_trap,
        interval: interval,
        max_batch_size: max_batch_size
      )
      @harvester.start
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
  end
end
