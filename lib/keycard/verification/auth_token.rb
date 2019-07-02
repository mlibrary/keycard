# frozen_string_literal: true

module Keycard
  class Verification
    # Identity verification based on an authorization token.
    #
    # The bound finder method is expected to take one parameter, the token as
    # presented by the user. This will typically need to be digested for
    # comparison with a stored version.
    class AuthToken < Verification
      def apply
        if token.nil?
          skipped("No auth_token found in request attributes")
        elsif (account = finder.call(token))
          succeeded(account, "Account found for supplied Authorization Token")
        else
          failed("Account not found for supplied Authorization Token")
        end
      end

      private

      def token
        attributes.auth_token
      end
    end
  end
end
