# frozen_string_literal: true

require "sequel_helper"
require "keycard/request/attributes"

RSpec.describe Keycard::Request::Attributes do
  let(:finder_attributes) { { baz: 'quux', finder_attr: 'value' } }
  let(:finder) do
    double(:finder, attributes_for: finder_attributes, identity_keys: [:finder_attr])
  end
  let(:rack_request) { double(:rack_request) }
  let(:attributes) { described_class.new(rack_request, finders: [finder]) }

  it "takes a request" do
    expect(attributes).not_to be(nil)
  end

  describe "#identity_keys" do
    it "includes user_pid and user_eid by default" do
      expect(described_class.new(double(:r), finders: []).identity_keys)
        .to contain_exactly(:user_pid, :user_eid)
    end
    it "lists combines its identity keys with those of its finders" do
      expect(attributes.identity_keys).to contain_exactly(:user_pid, :user_eid, :finder_attr)
    end
  end

  describe "#user_pid" do
    it { expect(attributes.user_pid).to be nil }
  end

  describe "#user_eid" do
    it { expect(attributes.user_eid).to be nil }
  end

  describe "#client_ip" do
    it { expect(attributes.client_ip).to be nil }
  end

  describe "#base" do
    it "is empty" do
      expect(attributes.base).to eq({})
    end
  end

  describe "#[]" do
    it "can get the value of a finder attribute" do
      expect(attributes[:finder_attr]).to eql('value')
    end
  end

  describe "#all" do
    let(:base_attributes) { { user_pid: 'pid', user_eid: 'eid', client_ip: '10.0.0.1', zilch: nil } }
    let(:finder_attributes) { { baz: 'quux', nada: nil } }
    before(:each) { allow(attributes).to receive(:base).and_return(base_attributes) }

    it "ignores nil attributes" do
      expect(attributes.all.keys).to_not include(:nada, :zilch)
    end

    it "includes base attributes and those from finders" do
      expect(attributes.all).to eql(base_attributes.merge(baz: 'quux'))
    end
  end

  describe "#identity" do
    let(:base_attributes) { { user_pid: 'pid', user_eid: 'eid', client_ip: '10.0.0.1' } }
    before(:each) { allow(attributes).to receive(:base).and_return(base_attributes) }

    it "includes pairs according to the identity_keys" do
      expect(attributes.identity).to eql(
        user_pid: 'pid',
        user_eid: 'eid',
        finder_attr: 'value'
      )
    end
  end

  describe "#supplemental" do
    context "with the default supplemental attributes" do
      let(:base_attributes) { { user_pid: 'user', client_ip: '10.0.0.1' } }
      before(:each) { allow(attributes).to receive(:base).and_return(base_attributes) }

      it "returns non-identity attributes" do
        expect(attributes.supplemental).to eq(baz: 'quux', client_ip: '10.0.0.1')
      end
    end

    context "with additional supplemental attributes in base attributes" do
      let(:base_attributes) { { user_pid: 'user', aardvarkName: 'Aardvark Jones' } }
      let(:expected) { { aardvarkName: 'Aardvark Jones', baz: 'quux' } }
      before(:each) { allow(attributes).to receive(:base).and_return(base_attributes) }

      it "returns the supplemental attributes" do
        expect(attributes.supplemental).to eql(expected)
      end
    end
  end
end
