# frozen_string_literal: true

module Keycard
  # A Notary is the primary entry point for authentication needs. It will
  # examine the request, session, and user-supplied credentials and provide
  # a {Certificate} with the results of identity verification.
  #
  # It relies on configuration to extract the correct attributes from each
  # request and to use the appropriate identity {Verification} methods. Each
  # verification method will attempt to locate a matching account and, for
  # those methods that involve user-supplied credentials, verify that are
  # correct for that account.
  class Notary
    # Create a Notary, which authenticates requests, verifying the identity of
    # the requester and issuing a resultant {Certificate} of authenticity.
    #
    # @param attributes_factory [Request::AttributesFactory] the factory to create
    #   {Request::Attributes} from the current request.
    # @param verifications [Array<callable>] the list of {Verification} strategies
    #   to use, in order, each wrapped as a callable initializer. Each factory
    #   should take (attributes, session, certificate, **credentials) and
    #   instantiate a Verification with a bound account/user finder.
    def initialize(attributes_factory:, verifications:)
      @attributes_factory = attributes_factory
      @verifications = verifications
    end

    # Create a default Notary instance, using common verifications and the
    # default AttributesFactory that creates request attributes based on the
    # Keycard.config.access value.
    #
    # This instance assumes that there is a `User` model with class methods
    # called `authenticate_by_id`, `authenticate_by_auth_token`, and
    # `authenticate_by_user_eid`. These should find the user with the given
    # id, authorization token, and EID/username. This is the order of
    # precedence, as well, corresponding to the following Verification classes:
    #
    # 1. {Keycard::Verification::SessionUserId}
    # 2. {Keycard::Verification::AuthToken}
    # 3. {Keycard::Verification::UserEid}
    #
    # @return [Keycard::Notary] a default Notary instance, bound to conventional
    #   authentication methods on a User class.
    def self.default
      new(
        attributes_factory: Keycard::Request::AttributesFactory.new,
        verifications: [
          Keycard::Verification::SessionUserId.bind_class_method(:User, :authenticate_by_id),
          Keycard::Verification::AuthToken.bind_class_method(:User, :authenticate_by_auth_token),
          Keycard::Verification::UserEid.bind_class_method(:User, :authenticate_by_user_eid)
        ]
      )
    end

    # Authenticate a request, giving a Certificate of the result.
    #
    # @param request [Rack::Request] the active request, used to extract attributes
    # @param session [Session] the active session, to be inspected with #[]
    # @return [Certificate] a {Certificate} with the authentication result
    def authenticate(request, session, **credentials)
      attributes = attributes_factory.for(request)
      Certificate.new.tap do |certificate|
        verifications.find do |factory|
          factory.call(attributes, session, certificate, credentials).apply
        end
      end
    end

    # Bypass normal authentication and create a Certificate for the given
    # user/account. This would typically only be used in development or other
    # administrative scenarios where it is appropriate to allow impersonation.
    def waive(account)
      Certificate.new.tap do |certificate|
        certificate.succeeded(account, "Administrative waiver for #{account}")
      end
    end

    # Issue an unconditional rejection Certificate. This is useful for a logout
    # workflow, where authenticating again yield a passing certificate. The
    # notion here is that the rejection would be cached just like any other
    # result, rather than simply clearing it for the request.
    #
    # A logout would typically be followed by an immediate redirect, but this
    # is a provision to ensure that the current request stays unauthenticated.
    #
    # @see {Keycard::ControllerMethods#logout} for how this is used in the
    #   context of the state of the current request.
    def reject
      Certificate.new.tap do |certificate|
        certificate.failed("Authentication rejected; session terminated")
      end
    end

    private

    attr_reader :attributes_factory
    attr_reader :verifications
  end
end
