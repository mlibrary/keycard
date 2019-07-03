# frozen_string_literal: true

RSpec.describe Keycard::Verification::AuthToken do
  subject(:verification) do
    described_class.new(attributes: attributes, session: {}, certificate: certificate, finder: finder)
  end

  let(:certificate) { Keycard::Certificate.new }
  let(:finder)      { double('UserModel', call: nil) }

  context "when request attributes include an authorization token the finder resolves" do
    let(:identity)   { { user_pid: "abc123" } }
    let(:attributes) { double('Attributes', auth_token: "raw-token", identity: identity) }
    let(:someuser)   { OpenStruct.new }

    before(:each) do
      allow(finder).to receive(:call).with("raw-token").and_return(someuser)
      verification.apply
    end

    it "is authenticated" do
      expect(certificate.authenticated?).to eq true
    end

    it "is marked CSRF-safe" do
      expect(certificate.csrf_safe?).to eq true
    end

    it "finds the user" do
      expect(certificate.account).to eq someuser
    end

    it "sets the identity attributes on the account" do
      expect(certificate.account.identity).to eq identity
    end
  end

  context "when request attributes do not include an authorization token" do
    let(:attributes) { double("Attributes", auth_token: nil) }

    before(:each) do
      verification.apply
    end

    it "is not authenticated" do
      expect(certificate.authenticated?).to eq false
    end

    it "is not failed" do
      expect(certificate.failed?).to eq false
    end

    it "does not set an account" do
      expect(certificate.account).to be_nil
    end
  end

  context "when request attributes include an authorization token finder rejects" do
    let(:attributes) { double("Attributes", auth_token: "bad-token") }

    before(:each) do
      verification.apply
    end

    it "is not authenticated" do
      expect(certificate.authenticated?).to eq false
    end

    it "is failed" do
      expect(certificate.failed?).to eq true
    end

    it "does not set an account" do
      expect(certificate.account).to be_nil
    end
  end
end
