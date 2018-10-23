# frozen_string_literal: true

require 'meeseeks/error'
require 'date'

module Meeseeks
  module Payload
    def self.for_group(group, metric, value, time)
      {
        group => self.for(metric, value, time)
      }
    end

    def self.for(metric, value, time = DateTime.now)
      {
        metric.to_s => {
          '_ts'    => time.to_datetime.strftime('%Q').to_i,
          '_value' => value,
          '_type'  => 'n'
        }
      }
    end

    def self.validate_type!(value)
      return if value.is_a?(String) || value.is_a?(Numeric)

      raise Errors::InvalidType, "#{value.class.name} values are not supported"
    end
  end
end
