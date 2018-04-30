# frozen_string_literal: true

require "keycard/request_attributes"

module Keycard
  RSpec.describe RequestAttributes do
    let(:inst_attributes) { {} }
    let(:finder)          { double(:finder, attributes_for: inst_attributes) }

    let(:client_attributes)  { {} }
    let(:resolver)           { double(:finder, attributes_for: client_attributes) }

    let(:request)            { double(:request) }
    let(:request_attributes) { described_class.new(request, resolver: resolver, finder: finder) }

    it "takes a request" do
      expect(request_attributes).not_to be(nil)
    end

    context "with a finder that returns an attribute" do
      let(:inst_attributes) { { foo: 'bar' } }

      it "can get the value of that attribute" do
        expect(request_attributes[:foo]).to eq('bar')
      end
    end

    context "with a resolver that returns an attribute" do
      let(:client_attributes) { { foo: 'bar' } }

      it "can get the value of that attribute" do
        expect(request_attributes[:foo]).to eq('bar')
      end
    end

    describe "#all" do
      let(:client_attributes) { { foo: 'bar' } }
      let(:inst_attributes)   { { baz: 'quux' } }
      let(:attributes)        { client_attributes.merge(inst_attributes) }

      it "returns all the attributes" do
        expect(request_attributes.all).to eq(attributes)
      end
    end
  end
end
