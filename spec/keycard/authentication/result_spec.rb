# frozen_string_literal: true

RSpec.describe Keycard::Authentication::Result do
  it "is unauthenticated to start" do
    result = described_class.new
    expect(result.authenticated?).to eq false
  end

  it "is not considered failed to start" do
    result = described_class.new
    expect(result.failed?).to eq false
  end

  it "is not considered CSRF-safe to start" do
    result = described_class.new
    expect(result.csrf_safe?).to eq false
  end

  context "when authentication is skipped" do
    let(:result)    { described_class.new }
    let!(:finished) { result.skipped("some message") }

    it "logs the message" do
      expect(result.log.first).to match(/SKIPPED.*some message/)
    end

    it "is not considered authenticated" do
      expect(result.authenticated?).to eq false
    end

    it "is not considered failed" do
      expect(result.failed?).to eq false
    end

    it "is not considered CSRF-safe" do
      expect(result.csrf_safe?).to eq false
    end

    it "signals that the authentication chain is incomplete" do
      expect(finished).to eq false
    end
  end

  context "when authentication succeeds" do
    let(:account)   { double('Account') }
    let(:result)    { described_class.new }
    let!(:finished) { result.succeeded(account, "some message") }

    it "logs the message" do
      expect(result.log.first).to match(/SUCCESS.*some message/)
    end

    it "is considered authenticated" do
      expect(result.authenticated?).to eq true
    end

    it "is not considered failed" do
      expect(result.failed?).to eq false
    end

    it "is not considered CSRF-safe" do
      expect(result.csrf_safe?).to eq false
    end

    it "records the account" do
      expect(result.account).to eq account
    end

    it "signals that the authentication chain is complete" do
      expect(finished).to eq true
    end
  end

  context "when authentication succeeds, declaring the request CSRF-safe" do
    let(:account) { double('Account') }
    let(:result) do
      described_class.new.tap do |result|
        result.succeeded(account, "some message", csrf_safe: true)
      end
    end

    it "is considered CSRF-safe" do
      expect(result.csrf_safe?).to eq true
    end
  end

  context "when authentication fails" do
    let(:result)    { described_class.new }
    let!(:finished) { result.failed("some message") }

    it "logs the message" do
      expect(result.log.first).to match(/FAILURE.*some message/)
    end

    it "is not considered authenticated" do
      expect(result.authenticated?).to eq false
    end

    it "is considered failed" do
      expect(result.failed?).to eq true
    end

    it "is not considered CSRF-safe" do
      expect(result.csrf_safe?).to eq false
    end

    it "signals that the authentication chain is complete" do
      expect(finished).to eq true
    end
  end
end
