# frozen_string_literal: true

require 'meeseeks/version'
require 'meeseeks/meeseeks'
require 'forwardable'

module Meeseeks
  extend SingleForwardable

  def self.instance
    @instance ||= Meeseeks.new
  end

  def_delegators :instance, *::Meeseeks::Meeseeks.instance_methods(false)
end
