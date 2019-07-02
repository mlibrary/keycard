# frozen_string_literal: true

RSpec.describe Keycard::Certificate do
  it "is unauthenticated to start" do
    certificate = described_class.new
    expect(certificate.authenticated?).to eq false
  end

  it "is not considered failed to start" do
    certificate = described_class.new
    expect(certificate.failed?).to eq false
  end

  context "when verification is skipped" do
    let(:certificate) { described_class.new }
    let!(:result)     { certificate.skipped("some message") }

    it "logs the message" do
      expect(certificate.log.first).to match(/SKIPPED.*some message/)
    end

    it "is not considered authenticated" do
      expect(certificate.authenticated?).to eq false
    end

    it "is not considered failed" do
      expect(certificate.failed?).to eq false
    end

    it "signals that the verification chain is incomplete" do
      expect(result).to eq false
    end
  end

  context "when verification succeeds" do
    let(:certificate) { described_class.new }
    let(:account)     { double('Account') }
    let!(:result)     { certificate.succeeded(account, "some message") }

    it "logs the message" do
      expect(certificate.log.first).to match(/SUCCESS.*some message/)
    end

    it "is considered authenticated" do
      expect(certificate.authenticated?).to eq true
    end

    it "is not considered failed" do
      expect(certificate.failed?).to eq false
    end

    it "records the account" do
      expect(certificate.account).to eq account
    end

    it "signals that the verification chain is complete" do
      expect(result).to eq true
    end
  end

  context "when verification fails" do
    let(:certificate) { described_class.new }
    let!(:result)     { certificate.failed("some message") }

    it "logs the message" do
      expect(certificate.log.first).to match(/FAILURE.*some message/)
    end

    it "is not considered authenticated" do
      expect(certificate.authenticated?).to eq false
    end

    it "is considered failed" do
      expect(certificate.failed?).to eq true
    end

    it "signals that the verification chain is complete" do
      expect(result).to eq true
    end
  end
end
