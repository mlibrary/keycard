# frozen_string_literal: true

require "keycard/proxied_resolver"

RSpec.describe Keycard::ProxiedResolver do
  let(:request) do
    double('request', env: { 'HTTP_X_REMOTE_USER' => 'user', 'HTTP_X_FORWARDED_FOR' => '10.0.0.1' })
  end

  let(:resolver) { described_class.new }

  it "extracts the username from HTTP_X_REMOTE_USER" do
    attributes = resolver.attributes_for(request)
    expect(attributes[:username]).to eq 'user'
  end

  it "extracts the client IP address from HTTP_X_FORWARDED_FOR" do
    attributes = resolver.attributes_for(request)
    expect(attributes[:client_ip]).to eq '10.0.0.1'
  end
end
