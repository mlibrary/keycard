# frozen_string_literal: true

RSpec.describe Keycard::Notary do
  subject(:notary) do
    described_class.new(attributes_factory: attributes_factory, verifications: verifications)
  end

  class Skip < Keycard::Verification
    def apply
      skipped("skip!")
    end
  end

  class Success < Keycard::Verification
    def apply
      succeeded(OpenStruct.new, "success!")
    end
  end

  class Failure < Keycard::Verification
    def apply
      failed("failure!")
    end
  end

  def make_factory(klass)
    lambda do |attributes, session, certificate, **credentials|
      klass.new(
        attributes: attributes,
        session: session,
        certificate: certificate,
        finder: nil,
        credentials: credentials
      )
    end
  end

  let(:skip)    { make_factory(Skip) }
  let(:success) { make_factory(Success) }
  let(:failure) { make_factory(Failure) }

  let(:attributes)         { double("Attributes", user_eid: "someuser", identity: { user_eid: "someuser" }) }
  let(:attributes_factory) { double("AttributesFactory", for: attributes) }

  context "with one successful verification" do
    let(:verifications) { [success] }
    let(:certificate) { notary.authenticate(double("Request"), double("Session")) }

    it "gives an authenticated certificate" do
      expect(certificate.authenticated?).to eq true
    end
  end

  context "with one successful verification followed by a skip" do
    let(:verifications) { [success, skip] }
    let(:certificate) { notary.authenticate(double("Request"), double("Session")) }

    it "gives an authenticated certificate" do
      expect(certificate.authenticated?).to eq true
    end

    it "does not apply the verification that would be skipped" do
      expect(certificate.log).not_to include(/skip!/)
    end
  end

  context "with one skip followed by a successful verification" do
    let(:verifications) { [skip, success] }
    let(:certificate) { notary.authenticate(double("Request"), double("Session")) }

    it "gives an authenticated certificate" do
      expect(certificate.authenticated?).to eq true
    end

    it "applies both verifications" do
      expect(certificate.log).to include(/skip!/, /success!/)
    end
  end

  context "with one skip followed by a successful and would-be failed verification" do
    let(:verifications) { [skip, success, failure] }
    let(:certificate) { notary.authenticate(double("Request"), double("Session")) }

    it "gives an authenticated certificate" do
      expect(certificate.authenticated?).to eq true
    end

    it "does not apply the failure after the success" do
      expect(certificate.log).not_to include(/failure!/)
    end
  end

  context "with one failed verification followed by a would-be successful verification" do
    let(:verifications) { [failure, success] }
    let(:certificate) { notary.authenticate(double("Request"), double("Session")) }

    it "gives a failed certificate" do
      expect(certificate.failed?).to eq true
    end

    it "does not apply the success after the failure" do
      expect(certificate.log).not_to include(/success!/)
    end
  end

  context "when waiving all verification for an account" do
    let(:verifications) { [failure] }
    let(:account)       { double("User") }
    let(:certificate)   { notary.waive(account) }

    it "gives an authenticated certificate" do
      expect(certificate.authenticated?).to eq true
    end

    it "sets the certificate's account" do
      expect(certificate.account).to eq(account)
    end
  end

  context "when rejecting a request" do
    let(:verifications) { [failure] }
    let(:account)       { double("User") }
    let(:certificate)   { notary.reject }

    it "gives an unauthenticated certificate" do
      expect(certificate.authenticated?).to eq false
    end

    it "gives an failed certificate" do
      expect(certificate.failed?).to eq true
    end
  end

  # Note that this is pretty nasty example group, but it serves to verify that
  # the late bindings to the User class methods are as documented, without
  # actually binding during test.
  describe "::default" do
    before(:each) do
      allow(Keycard::Verification::SessionUserId)
        .to receive(:bind_class_method)
        .with(:User, :authenticate_by_id)
        .and_return(proc {})
      allow(Keycard::Verification::AuthToken)
        .to receive(:bind_class_method)
        .with(:User, :authenticate_by_auth_token)
        .and_return(proc {})
      allow(Keycard::Verification::UserEid)
        .to receive(:bind_class_method)
        .with(:User, :authenticate_by_user_eid)
        .and_return(proc {})
    end

    let(:notary)  { described_class.default }
    let(:request) { double("Request", env: {}) }

    it "creates a Notary instance" do
      expect(notary).to be_a Keycard::Notary
    end

    it "binds SessionUserId to User.authenticate_by_id" do
      expect(Keycard::Verification::SessionUserId).to receive(:bind_class_method)
      notary
    end

    it "binds AuthToken to User.authenticate_by_auth_token" do
      expect(Keycard::Verification::AuthToken).to receive(:bind_class_method)
      notary
    end

    it "binds UserEid to User.authenticate_by_user_id" do
      expect(Keycard::Verification::UserEid).to receive(:bind_class_method)
      notary
    end
  end
end
