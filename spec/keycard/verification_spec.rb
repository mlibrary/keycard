# frozen_string_literal: true

RSpec.describe Keycard::Verification do
  class FakeUserModel
    def self.finder
    end
  end

  it "always skips" do
    certificate = double("Certificate")
    verification = described_class.new(
      attributes: {},
      session: {},
      certificate: certificate,
      finder: double
    )

    expect(certificate).to receive(:skipped)
    verification.apply
  end

  it "binds a proxy for its finder when given a class and method name" do
    factory = described_class.bind_class_method(:FakeUserModel, :finder)

    expect(described_class).to receive(:new) do |*_args, **kwargs|
      expect(kwargs[:finder]).to be_a Keycard::ReloadableProxy
    end

    factory.call(double, double, double)
  end

  it "binds a supplied callable as its finder" do
    callable = proc {}
    factory = described_class.bind(callable)

    expect(described_class).to receive(:new) do |*_args, **kwargs|
      expect(kwargs[:finder]).to eq callable
    end

    factory.call(double, double, double)
  end
end
