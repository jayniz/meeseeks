# frozen_string_literal: true

require 'net/http'
require 'json'

module Meeseeks
  class HTTPTrap
    attr_reader :last, :submit_count

    def initialize(data_submission_url)
      @uri = URI.parse(data_submission_url)
      @submit_count = 0
    end

    def submit(measurements)
      req = request(measurements)
      res = http.request(req)

      @last = OpenStruct.new(time: Time.now, request: req, response: res)
      @submit_count += 1

      JSON.parse res.body
    end

    def stats
      {
        submit_count: @submit_count,
        last_submit_at: @last&.time
      }
    end

    private

    def request(measurements)
      put.tap do |request|
        request.body = measurements.map(&:to_json).join("\n")
      end
    end

    def http
      Net::HTTP.new(@uri.host, @uri.port).tap do |http|
        http.use_ssl = @uri.scheme == 'https'
      end
    end

    def put
      Net::HTTP::Put.new(@uri.path, 'Content-Type' => 'application/json')
    end
  end
end
