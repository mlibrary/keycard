# frozen_string_literal: true

module Keycard
  # A Certificate is the central point of information about an authentication
  # attempt. It logs the verification methods attempted with their statuses
  # and reports the overall status. When authentication is successful, it holds
  # the user/account that was verified.
  class Certificate
    attr_reader :account
    attr_reader :log

    def initialize
      @account = nil
      @log = []
      @failed = false
      @csrf_safe = false
    end

    # Has this authentication completed successfully?
    def authenticated?
      !account.nil?
    end

    # Was there a failure for an attempted verification?
    def failed?
      @failed
    end

    # Does a completed verification protect from Cross-Site Request Forgery?
    #
    # This should be true in cases where the client presents authentication
    # that is not automatic, like an authentication token, rather than
    # automatic credentials like cookies or proxy-applied headers.
    def csrf_safe?
      @csrf_safe
    end

    # Log that the verification method was not applicable; continue the chain.
    #
    # @param message [String] a message about why the verification was skipped
    # @return [Boolean] false, indicating that the verification was inconclusive
    def skipped(message)
      log << "[SKIPPED] #{message}"
      false
    end

    # Log that the verification method failed; terminate the chain.
    #
    # @param message [String] a message about how the verification failed
    # @return [Boolean] true, indicating that futher verification should not occur
    def failed(message)
      log << "[FAILURE] #{message}"
      @failed = true
    end

    # Log that the verification method succeeded; terminate the chain.
    #
    # @param account [User|Account] Object/model representing the authenticated account
    # @param message [String] a message about how the verification succeeded
    # @param csrf_safe [Boolean] set to true if this verification method precludes
    #   Cross-Site Request Forgery, as with a non-cookie token sent with the request
    # @return [Boolean] true, indicating that futher verification should not occur
    def succeeded(account, message, csrf_safe: false)
      @account = account
      @csrf_safe ||= csrf_safe
      log << "[SUCCESS] #{message}"
      true
    end
  end
end
