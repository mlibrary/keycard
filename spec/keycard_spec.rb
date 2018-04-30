# frozen_string_literal: true

RSpec.describe Keycard do
  it "has a version number" do
    expect(Keycard::VERSION).not_to be nil
  end

  it "defaults to resolving client attributes directly" do
    expect(Keycard.resolver_class).to eq Keycard::ClientResolver
  end

  context "with a custom resolver" do
    before do
      @resolver = Keycard.resolver_class
    end

    it "allows setting a client resolver" do
      Keycard.resolver_class = Keycard::ProxiedResolver
      expect(Keycard.resolver_class).to eq Keycard::ProxiedResolver
    end

    after do
      Keycard.resolver_class = @resolver
    end
  end
end
