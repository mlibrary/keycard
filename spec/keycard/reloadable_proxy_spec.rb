# frozen_string_literal: true

RSpec.describe Keycard::ReloadableProxy do
  context "when the class and method are defined" do
    around(:each) do |example|
      class DummyClass
        def self.some_method
          :result
        end
      end
      example.run
      Object.send(:remove_const, :DummyClass)
    end

    it "calls the requested method" do
      proxy = described_class.new(:DummyClass, :some_method)
      expect(proxy.call).to eq :result
    end
  end

  context "when the class is reloaded" do
    around(:each) do |example|
      class DummyClass
        def self.some_method
          raise ArgumentError, "Simulating class replacement"
        end
      end
      example.run
      Object.send(:remove_const, :DummyClass)
    end

    it "calls the replaced method" do
      proxy = described_class.new(:DummyClass, :some_method)

      Object.send(:remove_const, :DummyClass)
      class DummyClass
        def self.some_method
          :new_result
        end
      end

      expect(proxy.call).to eq :new_result
    end
  end
end
