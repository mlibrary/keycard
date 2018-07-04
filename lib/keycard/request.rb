# frozen_string_literal: true

module Keycard
  # A container module for classes related to processing HTTP/Rack requests
  module Request
  end
end

require_relative 'request/attributes'
require_relative 'request/attributes_factory'
require_relative 'request/cosign_attributes'
require_relative 'request/direct_attributes'
require_relative 'request/proxied_attributes'
require_relative 'request/shibboleth_attributes'
