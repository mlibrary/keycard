# frozen_string_literal: true

require "keycard/version"
require "sequel"
require "ostruct"

# All of the Keycard components are contained within this top-level module.
module Keycard
  def self.config
    @config ||= OpenStruct.new(
      access: :direct,
      identity_attributes: %w[user_pid user_eid dlpsInstitutionId],
      supplemental_attributes: []
    )
  end
end

require "keycard/db"
require "keycard/railtie" if defined?(Rails)
require "keycard/institution_finder"
require "keycard/request"
