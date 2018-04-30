# frozen_string_literal: true

module Keycard
  # This resolver should be used when the application will serve HTTP requests
  # directly or through a proxy that sets the usual/trusted HTTP headers.
  class ClientResolver
    def attributes_for(request)
      {
        username: request.env['REMOTE_USER'],
        client_ip: request.env['REMOTE_ADDR']
      }
    end
  end
end
