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
    end

    # Has this authentication completed successfully?
    def authenticated?
      !account.nil?
    end

    # Was there a failure for an attempted verification?
    def failed?
      @failed
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
    # @return [Boolean] true, indicating that futher verification should not occur
    def succeeded(account, message)
      @account = account
      log << "[SUCCESS] #{message}"
      true
    end
  end
end
