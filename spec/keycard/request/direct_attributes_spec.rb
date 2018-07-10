# frozen_string_literal: true

require "keycard/request/direct_attributes"

RSpec.describe Keycard::Request::DirectAttributes do
  let(:addr)    { '10.0.0.1' }
  let(:base)    { double('request', env: { 'REMOTE_USER' => 'user', 'REMOTE_ADDR' => addr }) }
  let(:request) { described_class.new(base) }

  it "extracts the user_pid from REMOTE_USER" do
    expect(request.user_pid).to eq 'user'
  end

  it "extracts the user_eid from REMOTE_USER" do
    expect(request.user_eid).to eq 'user'
  end

  it "extracts the client IP address from REMOTE_ADDR" do
    expect(request.client_ip).to eq '10.0.0.1'
  end

  it "gives a hash of all of the base attributes" do
    expect(request.all).to eq(user_pid: 'user', user_eid: 'user', client_ip: '10.0.0.1')
  end

  context "with multiple remote addresses" do
    let(:addr) { '10.0.0.2, 10.0.0.1' }

    it "extracts the first IP from REMOTE_ADDR" do
      expect(request.client_ip).to eq '10.0.0.2'
    end
  end
end
