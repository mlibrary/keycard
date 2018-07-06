# frozen_string_literal: true

module Keycard
  module Request
    # This class extracts attributes for Shibboleth-enabled applications.
    # It trusts specific HTTP headers, so the app must not be exposed to direct
    # requests. The pid is typically a SAML2 Persistent NameID, which is very
    # long and cumbersome. The presence of an eid depends on attribute release
    # by the IdP, and will commonly be an eduPersonPrincipalName. The only two
    # attributes guaranteed to have usable values are the client_ip, for all
    # requests, and the user_pid, for requests from authenticated users.
    class ShibbolethAttributes < Attributes
      def base
        {
          user_pid:  user_pid,
          user_eid:  user_eid,
          client_ip: client_ip
        }
      end

      def user_pid
        get('HTTP_X_SHIB_PERSISTENT_ID')
      end

      def user_eid
        get('HTTP_X_SHIB_EDUPERSONPRINCIPALNAME')
      end

      def client_ip
        safe('HTTP_X_FORWARDED_FOR').split(',').first
      end

      def display_name
        get('HTTP_X_SHIB_DISPLAYNAME')
      end

      def scoped_affiliation
        safe('HTTP_X_SHIB_EDUPERSONSCOPEDAFFILIATION').split(';')
      end

      private

      def get(key)
        request.env[key]
      end

      def safe(key)
        get(key) || ''
      end
    end
  end
end
