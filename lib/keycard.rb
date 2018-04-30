# frozen_string_literal: true

require "keycard/version"
require "sequel"

# All of the Keycard components are contained within this top-level module.
module Keycard
  def self.resolver_class
    @resolver_class ||= ClientResolver
  end

  def self.resolver_class=(factory)
    @resolver_class = factory
  end
end

require "keycard/db"
require "keycard/railtie" if defined?(Rails)
require "keycard/request_attributes"
require "keycard/institution_finder"
require "keycard/client_resolver"
require "keycard/proxied_resolver"
