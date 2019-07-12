# frozen_string_literal: true

RSpec.describe Keycard::Authentication::UserEid do
  subject(:method) do
    described_class.new(attributes: attributes, session: {}, result: result, finder: finder)
  end

  let(:result) { Keycard::Authentication::Result.new }
  let(:finder) { double("UserModel", call: nil) }

  context "when request attributes include a user_eid the finder resolves" do
    let(:identity)   { { user_eid: "someuser" } }
    let(:attributes) { double("Attributes", user_eid: "someuser", identity: identity) }
    let(:someuser)   { OpenStruct.new }

    before(:each) do
      allow(finder).to receive(:call).with("someuser").and_return(someuser)
      method.apply
    end

    it "is authenticated" do
      expect(result.authenticated?).to eq true
    end

    it "finds the user" do
      expect(result.account).to eq someuser
    end

    it "sets the identity attributes on the account" do
      expect(result.account.identity).to eq identity
    end
  end

  context "when request attributes do not include a user_eid" do
    let(:attributes) { double("Attributes", user_eid: nil) }

    before(:each) do
      method.apply
    end

    it "is not authenticated" do
      expect(result.authenticated?).to eq false
    end

    it "is not failed" do
      expect(result.failed?).to eq false
    end

    it "does not set an account" do
      expect(result.account).to be_nil
    end
  end

  context "when request attributes include a user_eid the finder rejects" do
    let(:attributes) { double("Attributes", user_eid: "other") }

    before(:each) do
      method.apply
    end

    it "is not authenticated" do
      expect(result.authenticated?).to eq false
    end

    it "is failed" do
      expect(result.failed?).to eq true
    end

    it "does not set an account" do
      expect(result.account).to be_nil
    end
  end
end
