# frozen_string_literal: true

RSpec.describe Keycard::Verification::SessionUserId do
  subject(:verification) do
    described_class.new(attributes: attributes, session: session, certificate: certificate, finder: finder)
  end

  let(:certificate) { Keycard::Certificate.new }
  let(:identity)    { { user_pid: "abc123" } }
  let(:attributes)  { double("Attributes", identity: identity) }
  let(:finder)      { double("UserModel", call: nil) }

  context "when the session includes a user_id the finder resolves" do
    let(:session)  { { user_id: 1 } }
    let(:someuser) { OpenStruct.new }

    before(:each) do
      allow(finder).to receive(:call).with(1).and_return(someuser)
      verification.apply
    end

    it "is authenticated" do
      expect(certificate.authenticated?).to eq true
    end

    it "finds the user" do
      expect(certificate.account).to eq someuser
    end

    it "sets the identity attributes on the account" do
      expect(certificate.account.identity).to eq identity
    end
  end

  context "when the session does not include a user_id" do
    let(:session) { {} }

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

  context "when the session includes a user_id the finder rejects" do
    let(:session) { { user_id: -1 } }

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
