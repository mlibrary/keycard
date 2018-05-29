# frozen_string_literal: true

RSpec.describe Keycard do
  it "has a version number" do
    expect(Keycard::VERSION).not_to be nil
  end

  it "defaults to using the 'direct' access mode" do
    expect(Keycard.config.access).to eq :direct
  end
end
