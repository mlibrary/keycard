# frozen_string_literal: true

require "sequel_helper"
require "keycard/request"

RSpec.shared_examples "attribute factory" do |mode, klass|
  context "when Keycard is configured for #{mode} access" do
    before do
      @access = Keycard.config.access
      Keycard.config.access = mode
    end

    let(:factory) { described_class.new(finders: []) }
    let(:request) { double('request') }

    it "uses #{klass}" do
      expect(klass).to receive(:new).with(request, finders: []).and_return(request).at_least(:once)
      factory.for(request)
    end

    after do
      Keycard.config.access = @access
    end
  end
end

module Keycard::Request
  RSpec.describe AttributesFactory do
    access = {
      'direct'        => DirectAttributes,
      'proxy'         => ProxiedAttributes,
      'cosign'        => CosignAttributes,
      'shibboleth'    => ShibbolethAttributes,
      '(any unknown)' => DirectAttributes
    }
    access.each do |mode, klass|
      include_examples 'attribute factory', mode, klass
    end
  end
end
