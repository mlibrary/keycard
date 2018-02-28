# frozen_string_literal: true

require "keycard/institution_finder"
require "sequel_helper"

RSpec.describe Keycard::InstitutionFinder do
  subject { described_class.new }

  describe "#attributes_for" do
    let(:request) { double(:request) }

    before(:all) do
      @test_database = test_database
      @test_database[:aa_inst].insert()
    end

    before(:each) do
      allow(request).to receive(:get_header)
        .with('X-Forwarded-For')
        .and_return(client_ip)
    end

    subject { described_class.new.attributes_for(request) }

    context "with an ip with a single institution" do
      let(:client_ip) { "141.211.0.1" }

      it "returns a hash with (only) a dlpsInstitutionIds key" do
        expect(subject.keys).to contain_exactly('dlpsInstitutionIds')
      end

      it "returns the correct institution" do
        expect(subject['dlpsInstitutionIds']).to contain_exactly(1)
      end
    end

    context "with an ip with multiple institutions" do
      let(:client_ip) { "141.211.43.144" }
      it "returns the set of institutions" do
        expect(subject['dlpsInstitutionIds']).to contain_exactly(1, 490)
      end
    end

    context "with an IP address allowed and denied in the same institituion" do
      let(:client_ip) { "128.32.159.18" }
      it "returns an empty hash" do
        expect(subject).to eq({})
      end
    end

    context "with an IP address allowed in two insts and denied in one of them" do
      let(:client_ip) { "129.252.73.0" }
      it "returns the institution it wasn't denied from" do
        expect(subject['dlpsInstitutionIds']).to contain_exactly(1154)
      end
    end

    context "with an ip address not in any ranges" do
      let(:client_ip) { "1.2.3.4" }
      it "returns an empty hash" do
        expect(subject).to eq({})
      end
    end

    context "with an invalid IP address" do
      let(:client_ip) { "141.211.324.456" }

      it "returns an empty hash" do
        expect(subject).to eq({})
      end
    end

    context "with no ip" do
      let(:client_ip) { nil }

      it "returns an empty hash" do
        expect(subject).to eq({})
      end
    end
  end
end
