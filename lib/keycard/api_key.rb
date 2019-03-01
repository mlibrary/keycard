require "digest"
require "securerandom"

# A typical api key, ready to be encrypted.
class Keycard::ApiKey
  class HiddenKeyError < StandardError; end

  def initialize(key = SecureRandom.uuid)
    @key = key
  end

  def to_s
    key
  end

  def digest
    Digest::SHA256.hexdigest(key)
  end

  private
  attr_reader :key
end

class Keycard::ApiKey::Hidden < Keycard::ApiKey
  def to_s
    raise Keycard::ApiKey::HiddenKeyError, "Cannot display hashed/hidden keys"
  end

  def digest
    raise Keycard::ApiKey::HiddenKeyError, "Attempted to digest a hashed/hidden key"
  end
end
