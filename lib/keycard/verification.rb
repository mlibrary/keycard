# frozen_string_literal: true

module Keycard
  # An abstract identity verification method. Subclasses will inspect the
  # attributes and session for a request, attempting to match an account, and
  # recording the results on a {Certificate}.
  #
  # The general operation is that each verification method will have its
  # {#apply} method called. It should examine the attributes, session, or
  # credentials, and decide whether the required information is present. Then:
  #
  # 1. If the method is not applicable, call {#skipped} with a message naming
  #    the verification method and why it was not applicable.
  # 2. If the method is applicable, call the finder to attempt to locate the
  #    user/account and verify the method-specific information. For example,
  #    some methods will trust a username attribute that arrived by way of
  #    a reverse proxy, and the finder will only need to verify that a user
  #    exists with the given username. Other methods will need to verify that
  #    a token or password supplied hashes to the correct value.
  # 3. Depending on whether a user/account is identified and authenticated,
  #    call {#succeeded} with the account and a message, or {#failed} with
  #    a message.
  #
  # Each of the status methods appends to a certificate for diagnostic or audit
  # purposes and affects whether the chain of verification should continue or
  # be terminated. If a verification is skipped, the next one will be
  # attempted. If it succeeds, or fails, the chain will be terminated. If it
  # succeeds, the identity attributes will be assigned to the account, and it
  # will be set as the account on the certificate.
  #
  # For integration with larger-scale configuration (like how request
  # attributes should be extracted and which verification methods should be
  # used, in what order), see {Keycard::Notary}.
  #
  # For stateful integration with controllers (like the notions of a "current
  # user" and logging in and out), see {Keycard::ControllerMethods}.
  class Verification
    # Create a Verification, based on specific request attributes and a session
    # object. This base class should not be used directly, nor should this
    # initializer, typically.
    #
    # In order to connect the subclass to an application-specific and
    # method-specific means of locating users/accounts, a "finder" should be
    # bound in to a factory that will apply it along with the remaining
    # parameters for each request.
    #
    #
    # @see Keycard::Notary.default for an example of binding
    #
    # @param attributes [Keycard::Request::Attributes] attributes extracted from the current request
    # @param session [Session|Hash] the session object for the current request
    # @param certificate [Keycard::Certificate] a certificate for recording the outcome of this
    #   verification method
    # @param finder [#call] a callable to look for the matching user/account if the verification
    #   method applies; that is, if there are appropriate attributes or credentials supplied such
    #   that the identity should be verified.
    # @param credentials [KeywordArgs] user-supplied credentials that will not be present in the
    #   attributes or session, for example, a username and password for a login form. These will
    #   be passed to the {#apply} method.
    def initialize(attributes:, session:, certificate:, finder:, **credentials)
      @attributes = attributes
      @session = session
      @certificate = certificate
      @finder = finder
      @credentials = credentials
    end

    # Bind a finder callable and yield a factory lambda to create a
    # Verification with all of the other parameters. This allows for
    # configuring a prototype at the system level and applying items that vary
    # per request more conveniently.

    def self.bind(finder)
      lambda do |attributes, session, certificate, **credentials|
        new(
          attributes: attributes,
          session: session,
          certificate: certificate,
          finder: finder,
          credentials: credentials
        )
      end
    end

    # Bind a class method as a finder. This is more convenient form than
    # {::bind} because it uses a {Keycard::ReloadableProxy}, making it easier
    # to work with finder methods on ActiveRecord models, which are reloaded in
    # development on each change, without restarting the server.
    def self.bind_class_method(finder_class, method)
      bind(ReloadableProxy.new(finder_class, method))
    end

    # Attempt to apply this verification method and record the status on the
    # certificate.
    def apply
      skipped("Base Verification is always skipped; it should not be used directly.")
    end

    private

    def skipped(message)
      certificate.skipped(message)
    end

    def succeeded(account, message)
      account.identity = attributes.identity
      certificate.succeeded(account, message)
    end

    def failed(message)
      certificate.failed(message)
    end

    attr_reader :attributes
    attr_reader :session
    attr_reader :certificate
    attr_reader :finder
    attr_reader :credentials
  end
end

require_relative "verification/auth_token"
require_relative "verification/session_user_id"
require_relative "verification/user_eid"
