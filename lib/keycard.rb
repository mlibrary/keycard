# frozen_string_literal: true

require "keycard/version"
require "sequel"
require "ostruct"

# All of the Keycard components are contained within this top-level module.
module Keycard
  class AuthenticationRequired < StandardError; end
  class AuthenticationFailed < StandardError; end

  def self.config
    @config ||= OpenStruct.new(
      access: :direct
    )
  end
end

require "keycard/digest_key"
require "keycard/db"
require "keycard/railtie" if defined?(Rails)
require "keycard/institution_finder"
require "keycard/request"
require "keycard/token"

require "keycard/certificate"
require "keycard/verification"
require "keycard/notary"

require "keycard/reloadable_proxy"
require "keycard/controller_methods"
