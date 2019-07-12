# frozen_string_literal: true

RSpec.describe Keycard::Notary do
  subject(:notary) do
    described_class.new(attributes_factory: attributes_factory, methods: methods)
  end

  class Skip < Keycard::Authentication::Method
    def apply
      skipped("skip!")
    end
  end

  class Success < Keycard::Authentication::Method
    def apply
      succeeded(OpenStruct.new, "success!")
    end
  end

  class Failure < Keycard::Authentication::Method
    def apply
      failed("failure!")
    end
  end

  def make_factory(klass)
    lambda do |attributes, session, result, **credentials|
      klass.new(
        attributes: attributes,
        session: session,
        result: result,
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

  context "with one successful method" do
    let(:methods) { [success] }
    let(:result)  { notary.authenticate(double("Request"), double("Session")) }

    it "gives an authenticated result" do
      expect(result.authenticated?).to eq true
    end
  end

  context "with one successful method followed by a skip" do
    let(:methods) { [success, skip] }
    let(:result) { notary.authenticate(double("Request"), double("Session")) }

    it "gives an authenticated result" do
      expect(result.authenticated?).to eq true
    end

    it "does not apply the method that would be skipped" do
      expect(result.log).not_to include(/skip!/)
    end
  end

  context "with one skip followed by a successful method" do
    let(:methods) { [skip, success] }
    let(:result)  { notary.authenticate(double("Request"), double("Session")) }

    it "gives an authenticated result" do
      expect(result.authenticated?).to eq true
    end

    it "applies both methods" do
      expect(result.log).to include(/skip!/, /success!/)
    end
  end

  context "with one skip followed by a successful and would-be failed method" do
    let(:methods) { [skip, success, failure] }
    let(:result)  { notary.authenticate(double("Request"), double("Session")) }

    it "gives an authenticated result" do
      expect(result.authenticated?).to eq true
    end

    it "does not apply the failure after the success" do
      expect(result.log).not_to include(/failure!/)
    end
  end

  context "with one failed method followed by a would-be successful method" do
    let(:methods) { [failure, success] }
    let(:result)  { notary.authenticate(double("Request"), double("Session")) }

    it "gives a failed result" do
      expect(result.failed?).to eq true
    end

    it "does not apply the success after the failure" do
      expect(result.log).not_to include(/success!/)
    end
  end

  context "when waiving all authentication for an account" do
    let(:methods) { [failure] }
    let(:account) { double("User") }
    let(:result)  { notary.waive(account) }

    it "gives an authenticated result" do
      expect(result.authenticated?).to eq true
    end

    it "sets the result's account" do
      expect(result.account).to eq(account)
    end
  end

  context "when rejecting a request" do
    let(:methods) { [failure] }
    let(:account) { double("User") }
    let(:result)  { notary.reject }

    it "gives an unauthenticated result" do
      expect(result.authenticated?).to eq false
    end

    it "gives a failed result" do
      expect(result.failed?).to eq true
    end
  end

  # Note that this is pretty nasty example group, but it serves to verify that
  # the late bindings to the User class methods are as documented, without
  # actually binding during test.
  describe "::default" do
    before(:each) do
      allow(Keycard::Authentication::SessionUserId)
        .to receive(:bind_class_method)
        .with(:User, :authenticate_by_id)
        .and_return(proc {})
      allow(Keycard::Authentication::AuthToken)
        .to receive(:bind_class_method)
        .with(:User, :authenticate_by_auth_token)
        .and_return(proc {})
      allow(Keycard::Authentication::UserEid)
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
      expect(Keycard::Authentication::SessionUserId).to receive(:bind_class_method)
      notary
    end

    it "binds AuthToken to User.authenticate_by_auth_token" do
      expect(Keycard::Authentication::AuthToken).to receive(:bind_class_method)
      notary
    end

    it "binds UserEid to User.authenticate_by_user_id" do
      expect(Keycard::Authentication::UserEid).to receive(:bind_class_method)
      notary
    end
  end
end
