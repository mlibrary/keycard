# frozen_string_literal: true

require "keycard/digest_key"
require "securerandom"

RSpec.describe Keycard::Token do
  let(:token) { "somereallycooltoken" }
  let(:header_value) { "Token token=\"#{token}\", opt=\"someopt\"" }

  describe "::rfc7235" do
    it "returns the token" do
      expect(described_class.rfc7235(header_value)).to eql(token)
    end
  end
end
