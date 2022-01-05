# frozen_string_literal: true

require "keycard/digest_key"
require "securerandom"

RSpec.describe Keycard::DigestKey do
  let(:hidden_uuid) { "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" }
  let(:uuid) { SecureRandom.uuid }
  let(:digest) { Digest::SHA256.hexdigest(uuid) }
  let(:new_key) { described_class.new(key: uuid) }
  let(:hidden_key) { described_class.new(digest) }

  describe "#to_s" do
    it "displays new keys" do
      expect(new_key.to_s).to eql(uuid)
    end

    it "hides hidden keys" do
      expect(hidden_key.to_s).to eql(hidden_uuid)
    end

    it "defaults to a uuid" do
      allow(SecureRandom).to receive(:uuid).and_return("a uuid")
      expect(described_class.new.to_s).to eql("a uuid")
    end
  end

  describe "#value" do
    it "returns the new key" do
      expect(new_key.value).to eql(uuid)
    end

    it "throws on a hidden key" do
      expect { hidden_key.value }
        .to raise_error described_class::HiddenKeyError
    end
  end

  describe "#digest" do
    it "new keys return the hashed value" do
      expect(new_key.digest).to eql(digest)
    end

    it "hidden keys return the hashed value" do
      expect(hidden_key.digest).to eql(digest)
    end
  end

  %i[== eql?].each do |m|
    describe "##{m}" do
      it "compares the digest to anything with a to_s method" do
        thing = Struct.new(:to_s).new(digest)
        expect(new_key.send(m, thing)).to be true
      end

      it "instantiates a new key every time" do
        expect(described_class.new.send(m, described_class.new)).to be false
      end

      it "new keys are equal if their keys are equal" do
        expect(described_class.new(key: uuid).send(m, described_class.new(key: uuid)))
          .to be true
      end

      it "new keys are unequal if their keys are unequal" do
        expect(described_class.new(key: uuid).send(m, described_class.new(key: "foo")))
          .to be false
      end

      it "new key == hidden key if their digests match" do
        expect(described_class.new(key: uuid).send(m, described_class.new(digest)))
          .to be true
      end

      it "hidden key == new key if their digests match" do
        expect(described_class.new(digest).send(m, described_class.new(key: uuid)))
          .to be true
      end

      it "new key != hidden key if their digests mismatch" do
        expect(described_class.new(key: uuid).send(m, described_class.new("foo")))
          .to be false
      end

      it "hidden key != new key if their digests mismatch" do
        expect(described_class.new("foo").send(m, described_class.new(key: uuid)))
          .to be false
      end

      it "hidden key == hidden key if their digests match" do
        expect(described_class.new(digest).send(m, described_class.new(digest)))
          .to be true
      end

      it "hidden key != hidden key if their digests match" do
        expect(described_class.new(digest).send(m, described_class.new("foo")))
          .to be false
      end
    end
  end
end
