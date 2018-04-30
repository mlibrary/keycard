# frozen_string_literal: true

module Keycard
  # This resolver should be used when the application will be served behind a
  # reverse proxy. It relies on the trusted relationship with the proxy to use
  # HTTP headers for forwarded values.
  class ProxiedResolver
    # The typical headers forwarded are X-Forwarded-User and X-Forwarded-For,
    # which, somewhat confusingly, are transposed into HTTP_X_REMOTE_USER and
    # HTTP_X_FORWARDED_FOR once the Rack request is assembled.
    def attributes_for(request)
      {
        username: request.env['HTTP_X_REMOTE_USER'],
        client_ip: request.env['HTTP_X_FORWARDED_FOR']
      }
    end
  end
end
