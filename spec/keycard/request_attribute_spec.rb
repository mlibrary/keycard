# frozen_string_literal: true

require "sequel_helper"
require "keycard/request_attributes"
require "keycard/proxied_request"
require "keycard/direct_request"

module Keycard
  RSpec.describe RequestAttributes do
    let(:inst_attributes) { {} }
    let(:finder)          { double(:finder, attributes_for: inst_attributes) }

    let(:user_attributes)    { { username: 'user' } }
    let(:request)            { double(:request, attributes: user_attributes, client_ip: '10.0.0.1' ) }
    let(:factory)            { double('request factory', for: request) }
    let(:request_attributes) { described_class.new(request, finder: finder, request_factory: factory) }

    it "takes a request" do
      expect(request_attributes).not_to be(nil)
    end

    it "includes a username" do
      expect(request_attributes[:username]).not_to be nil
    end

    context "with a finder that returns an attribute" do
      let(:inst_attributes) { { foo: 'bar' } }

      it "can get the value of that attribute" do
        expect(request_attributes[:foo]).to eq('bar')
      end
    end

    describe "#all" do
      let(:user_attributes) { { username: 'user' } }
      let(:inst_attributes) { { baz: 'quux' } }
      let(:attributes)      { user_attributes.merge(inst_attributes) }

      it "returns all the attributes" do
        expect(request_attributes.all).to eq attributes
      end
    end

    describe "#identity" do
      let(:user_attributes) { { username: 'user', bogus: 'junk' } }
      let(:inst_attributes) { { baz: 'quux' } }
      let(:attributes)      { user_attributes.merge(inst_attributes) }

      it "returns the identity attributes" do
        expect(request_attributes.identity).to eq({ username: 'user' })
      end
    end

    describe "#supplemental" do

      context "with the default supplemental attributes" do
        let(:user_attributes) { { username: 'user' } }
        let(:inst_attributes) { { baz: 'quux' } }
        let(:attributes)      { { }}

        xit "returns the supplemental attributes" do
          expect(request_attributes.supplemental).to eq attributes
        end
      end

      context "when Keycard is configured to deliver displayName as a supplemental attribute" do
        let(:user_attributes) { { username: 'user', aardvarkName: 'Aardvark Jones' } }
        let(:inst_attributes) { { baz: 'quux' } }
        let(:attributes)      { { aardvarkName: 'Aardvark Jones' }}

        before do
          @supplemental = Keycard.config.supplemental_attributes
          Keycard.config.supplemental_attributes = ['aardvarkName']
        end

        after do
          Keycard.config.supplemental_attributes = @supplemental
        end

        xit "returns the supplemental attributes" do
          expect(request_attributes.supplemental).to eq attributes
        end
      end
    end

    context "when Keycard is configured for proxied access" do
      before do
        @access = Keycard.config.access
        Keycard.config.access = 'proxy'
      end

      let(:base) do
        double('base', env: {
                 'HTTP_X_FORWARDED_FOR' => '10.0.0.1', 'HTTP_X_REMOTE_USER' => 'user'
               })
      end
      let(:request) { double('request', attributes: { username: 'user' }, client_ip: '10.0.0.1') }

      it "uses ProxiedRequest" do
        expect(ProxiedRequest).to receive(:for).with(base).and_return(request).at_least(:once)
        described_class.new(base).all
      end

      after do
        Keycard.config.access = @access
      end
    end

    context "when Keycard is configured for direct access" do
      before do
        @access = Keycard.config.access
        Keycard.config.access = 'direct'
      end

      let(:base) do
        double('base', env: {
                 'REMOTE_ADDR' => '10.0.0.1', 'REMOTE_USER' => 'user'
               })
      end
      let(:request) { double('request', attributes: { username: 'user', }, client_ip: '10.0.0.1') }

      it "uses DirectRequest" do
        expect(DirectRequest).to receive(:for).with(base).and_return(request).at_least(:once)
        described_class.new(base).all
      end

      after do
        Keycard.config.access = @access
      end
    end

    context "when Keycard is configured for unknown access" do
      before do
        @access = Keycard.config.access
        Keycard.config.access = 'badvalue'
      end

      let(:base) do
        double('base', env: {
                 'REMOTE_ADDR' => '10.0.0.1', 'REMOTE_USER' => 'user'
               })
      end
      let(:request) { double('request', attributes: { username: 'user', }, client_ip: '10.0.0.1') }

      it "uses DirectRequest" do
        expect(DirectRequest).to receive(:for).with(base).and_return(request).at_least(:once)
        described_class.new(base).all
      end

      after do
        Keycard.config.access = @access
      end
    end
  end
end
