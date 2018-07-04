# frozen_string_literal: true

module Keycard
  module Request
    class AttributesFactory
      def initialize(finders: [InstitutionFinder.new])
        @finders = finders
      end

      def for(request)
        access = Keycard.config.access.to_sym
        case access
        when :direct
          DirectAttributes
        when :proxy
          ProxiedAttributes
        when :cosign
          CosignAttributes
        when :shibboleth
          ShibbolethAttributes
        else
          # TODO: Warn about this once to the appropriate log; probably in a config check, not here.
          # puts "Keycard does not recognize the '#{access}' access mode, using 'direct'."
          DirectAttributes
        end.new(request, finders: finders)
      end

      private

      attr_reader :finders
    end
  end
end
