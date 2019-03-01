# frozen_string_literal: true

require "keycard/version"
require "sequel"
require "ostruct"

# All of the Keycard components are contained within this top-level module.
module Keycard
  def self.config
    @config ||= OpenStruct.new(
      access: :direct
    )
  end
end

require "keycard/api_key"
require "keycard/db"
require "keycard/railtie" if defined?(Rails)
require "keycard/institution_finder"
require "keycard/request"
