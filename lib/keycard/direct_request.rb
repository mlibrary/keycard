# frozen_string_literal: true

module Keycard
  # This request wrapper should be used when the application will serve HTTP
  # requests directly or through a proxy that sets up the usual environment.
  class DirectRequest < SimpleDelegator
    def self.for(request)
      new(request)
    end

    def attributes
      {
        username: username,
        client_ip: client_ip,
      }
    end

    def username
      env['REMOTE_USER'] || ''
    end

    def client_ip
      (env['REMOTE_ADDR'] || '').split(',').first || ''
    end
  end
end
