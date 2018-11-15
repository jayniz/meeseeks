# frozen_string_literal: true

require 'meeseeks/version'
require 'meeseeks/meeseeks'
require 'forwardable'

module Meeseeks
  extend SingleForwardable

  def self.instance
    @instance ||= Meeseeks.new(*(@configuration || {}))
  end

  def self.configure(*args)
    @configuration = args
  end

  def self.implode!
    @instance&.implode!
    @instance = nil
  end

  def_delegators(
    :instance,
    *(::Meeseeks::Meeseeks.instance_methods(false) - [:implode!])
  )
end
