# frozen_string_literal: true

module Keycard
  # This request wrapper should be used when the application will be served
  # behind a reverse proxy. It relies on the trusted relationship with the
  # proxy to use HTTP headers for forwarded values.
  #
  # The typical headers forwarded are X-Forwarded-User and X-Forwarded-For,
  # which, somewhat confusingly, are transposed into HTTP_X_REMOTE_USER and
  # HTTP_X_FORWARDED_FOR once the Rack request is assembled.
  class ProxiedRequest < SimpleDelegator
    def self.for(request)
      new(request)
    end

    def username
      env['HTTP_X_REMOTE_USER'] || ''
    end

    def client_ip
      (env['HTTP_X_FORWARDED_FOR'] || '').split(',').first || ''
    end
  end
end
