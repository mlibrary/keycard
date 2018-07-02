# frozen_string_literal: true

require "keycard/direct_request"

RSpec.describe Keycard::DirectRequest do
  let(:addr)    { '10.0.0.1' }
  let(:base)    { double('request', env: { 'REMOTE_USER' => 'user', 'REMOTE_ADDR' => addr }) }
  let(:request) { described_class.new(base) }

  it "extracts the username from REMOTE_USER" do
    expect(request.username).to eq 'user'
  end

  it "extracts the client IP address from REMOTE_ADDR" do
    expect(request.client_ip).to eq '10.0.0.1'
  end

  it "gives a hash of all of the usable attributes" do
    expect(request.attributes).to eq({ username: 'user', client_ip: '10.0.0.1' })
  end

  context "with multiple remote addresses" do
    let(:addr) { '10.0.0.2, 10.0.0.1' }

    it "extracts the first IP from REMOTE_ADDR" do
      expect(request.client_ip).to eq '10.0.0.2'
    end
  end

  describe "#for" do
    let(:request) { described_class.for(base) }

    it "gives a DirectRequest" do
      expect(request).to be_a Keycard::DirectRequest
    end
  end
end
