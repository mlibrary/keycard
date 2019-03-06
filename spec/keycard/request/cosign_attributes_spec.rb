# frozen_string_literal: true

require "keycard/request/cosign_attributes"

RSpec.describe Keycard::Request::CosignAttributes do
  let(:attributes) { described_class.new(rack_request) }

  context "with typical forwarded headers" do
    let(:rack_request) do
      double(:rack_request, env: {
               'HTTP_X_REMOTE_USER' => 'user',
               'HTTP_X_FORWARDED_FOR' => '10.0.0.1'
             })
    end

    it "extracts the user_pid from HTTP_X_REMOTE_USER" do
      expect(attributes.user_pid).to eq 'user'
    end

    it "extracts the user_eid from HTTP_X_REMOTE_USER" do
      expect(attributes.user_eid).to eq 'user'
    end

    it "extracts the client IP address from HTTP_X_FORWARDED_FOR" do
      expect(attributes.client_ip).to eq '10.0.0.1'
    end

    it "gives a hash of all of the base attributes" do
      expect(attributes.all).to eq(user_pid: 'user', user_eid: 'user', client_ip: '10.0.0.1')
    end
  end

  context "with no forwarded headers" do
    let(:rack_request) { double(:rack_request, env: {}) }

    it "the user_pid is empty" do
      expect(attributes.user_pid).to be_nil
    end

    it "the user_eid is empty" do
      expect(attributes.user_eid).to be_nil
    end

    it "the client_ip is empty (this would be a proxy configuration error)" do
      expect(attributes.client_ip).to be_nil
    end
  end

  context "with multiple forwarded addresses" do
    let(:rack_request) do
      double(:rack_request, env: {
               'HTTP_X_FORWARDED_FOR' => '10.0.0.2, 10.0.0.1'
             })
    end

    it "extracts the first address" do
      expect(attributes.client_ip).to eq '10.0.0.2'
    end
  end
end
