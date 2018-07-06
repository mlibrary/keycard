# frozen_string_literal: true

require "sequel_helper"
require "keycard/request/attributes"

module Keycard::Request
  RSpec.describe Attributes do
    let(:inst_attributes) { {} }
    let(:finder) do
      double(:finder, attributes_for: inst_attributes, identity_keys: [:inst_attr])
    end

    let(:user_attributes)    { { username: 'user' } }
    let(:request)            { double(:request, attributes: user_attributes, client_ip: '10.0.0.1' ) }
    let(:request_attributes) { described_class.new(request, finders: [finder]) }

    it "takes a request" do
      expect(request_attributes).not_to be(nil)
    end

    it "lists combines its identity keys with those of its finders" do
      expect(request_attributes.identity_keys).to contain_exactly(:user_pid, :user_eid, :inst_attr)
    end

    it "does not give a value for user_pid" do
      expect(request_attributes.user_pid).to be nil
    end

    it "does not give a value for user_eid" do
      expect(request_attributes.user_eid).to be nil
    end

    it "does not give a value for client_ip" do
      expect(request_attributes.client_ip).to be nil
    end

    it "gives empty base attributes" do
      expect(request_attributes.base).to eq({})
    end

    context "with a finder that returns an attribute" do
      let(:inst_attributes) { { inst_attr: 'value', foo: 'bar' } }

      it "can get the value of an attribute" do
        expect(request_attributes[:inst_attr]).to eq('value')
      end

      it "merges identity attributes according to the finder's identity_keys" do
        expect(request_attributes.identity[:inst_attr]).to eq 'value'
      end

      it "passes through supplemental attributes" do
        expect(request_attributes.supplemental[:foo]).to eq('bar')
      end
    end

    describe "#all" do
      let(:user_attributes) { { username: 'user' } }
      let(:inst_attributes) { { baz: 'quux' } }

      it "returns only the institutional attribute because pid, eid, and IP are nil" do
        expect(request_attributes.all).to eq inst_attributes
      end
    end

    describe "#identity" do
      let(:base_attributes) do
        { user_pid: 'pid', user_eid: 'eid', client_ip: '10.0.0.1' } 
      end
      let(:inst_attributes) { { baz: 'quux' } }

      it "returns the identity attributes" do
        allow(request_attributes).to receive(:base).and_return(base_attributes)
        expect(request_attributes.identity).to eq({ user_pid: 'pid', user_eid: 'eid' })
      end
    end

    describe "#supplemental" do

      context "with the default supplemental attributes" do
        let(:base_attributes) { { user_pid: 'user', client_ip: '10.0.0.1' } }
        let(:inst_attributes) { { baz: 'quux' } }
        let(:attributes)      { { baz: 'quux' } }

        it "returns the supplemental attributes" do
          expect(request_attributes.supplemental).to eq attributes
        end
      end

      context "when Keycard is configured to deliver displayName as a supplemental attribute" do
        let(:base_attributes) { { user_pid: 'user', aardvarkName: 'Aardvark Jones' } }
        let(:inst_attributes) { { baz: 'quux' } }
        let(:attributes)      { { aardvarkName: 'Aardvark Jones', baz: 'quux' }}

        before do
          @supplemental = Keycard.config.supplemental_attributes
          Keycard.config.supplemental_attributes = ['aardvarkName']
        end

        after do
          Keycard.config.supplemental_attributes = @supplemental
        end

        it "returns the supplemental attributes" do
          allow(request_attributes).to receive(:base).and_return(base_attributes)
          expect(request_attributes.supplemental).to eq attributes
        end
      end
    end
  end
end
