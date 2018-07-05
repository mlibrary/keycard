# frozen_string_literal: true

require "keycard/request/proxied_attributes"

RSpec.describe Keycard::Request::ProxiedAttributes do
  context "with typical forwarded headers" do
    let(:base) do
      double('base request', env: {
               'HTTP_X_REMOTE_USER' => 'user',
               'HTTP_X_FORWARDED_FOR' => '10.0.0.1'
             })
    end
    let(:request) { described_class.new(base) }

    it "extracts the user_pid from HTTP_X_REMOTE_USER" do
      expect(request.user_pid).to eq 'user'
    end

    it "extracts the user_eid from HTTP_X_REMOTE_USER" do
      expect(request.user_eid).to eq 'user'
    end

    it "extracts the client IP address from HTTP_X_FORWARDED_FOR" do
      expect(request.client_ip).to eq '10.0.0.1'
    end

    it "gives a hash of all of the base attributes" do
      expect(request.all).to eq({ user_pid: 'user', user_eid: 'user', client_ip: '10.0.0.1' })
    end
  end

  context "with no forwarded headers" do
    let(:base)    { double('base request', env: {}) }
    let(:request) { described_class.new(base) }

    it "the user_pid is empty" do
      expect(request.user_pid).to eq ''
    end

    it "the user_eid is empty" do
      expect(request.user_eid).to eq ''
    end

    it "the client_ip is empty" do
      expect(request.client_ip).to eq ''
    end
  end

  context "with multiple forwarded addresses" do
    let(:base) do
      double('base request', env: {
               'HTTP_X_FORWARDED_FOR' => '10.0.0.2, 10.0.0.1'
             })
    end
    let(:request) { described_class.new(base) }

    it "extracts the first address" do
      expect(request.client_ip).to eq '10.0.0.2'
    end
  end
end
