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
        super.merge(shib_attributes)
      end

      def user_pid
        getenv('HTTP_X_SHIB_PERSISTENT_ID')
      end

      def user_eid
        getenv('HTTP_X_SHIB_EDUPERSONPRINCIPALNAME')
      end

      def client_ip
        getenv('HTTP_X_FORWARDED_FOR').split(',').first || ''
      end

      def display_name
        getenv('HTTP_X_SHIB_DISPLAYNAME')
      end

      def scoped_affiliation
        getenv('HTTP_X_SHIB_EDUPERSONSCOPEDAFFILIATION').split(';')
      end

      private

      def getenv(key)
        request.env[key] || ''
      end

      def shib_attributes
        {
          displayName: display_name,
          eduPersonScopedAffiliation: scoped_affiliation
        }
      end
    end
  end
end
