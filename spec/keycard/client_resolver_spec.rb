# frozen_string_literal: true

require "keycard/client_resolver"

RSpec.describe Keycard::ClientResolver do
  let(:request)  { double('request', env: { 'REMOTE_USER' => 'user', 'REMOTE_ADDR' => '10.0.0.1' }) }
  let(:resolver) { described_class.new }

  it "extracts the username from REMOTE_USER" do
    attributes = resolver.attributes_for(request)
    expect(attributes[:username]).to eq 'user'
  end

  it "extracts the client IP address from REMOTE_ADDR" do
    attributes = resolver.attributes_for(request)
    expect(attributes[:client_ip]).to eq '10.0.0.1'
  end
end
