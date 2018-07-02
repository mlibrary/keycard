# frozen_string_literal: true

module Keycard
  # This class is responsible for extracting the user attributes (i.e. the
  # complete set of things that determine the user's #identity), given a Rack
  # request.
  class RequestAttributes
    def initialize(request, finder: InstitutionFinder.new, request_factory: default_factory)
      @request  = request_factory.for(request)
      @finder   = finder
    end

    def [](attr)
      all[attr]
    end

    def all
      user_attributes.merge(finder.attributes_for(request))
    end

    def identity
      all
    end

    def supplemental
#      require "pry"
#      binding.pry
      all.select { |k,v| Keycard.config.supplemental_attributes.include?(k) }
    end

    private

    def user_attributes
      { username: request.username }
    end

    def default_factory
      access = Keycard.config.access.to_sym
      case access
      when :direct
        DirectRequest
      when :proxy
        ProxiedRequest
      else
        # TODO: Warn about this once to the appropriate log; probably in a config check, not here.
        # puts "Keycard does not recognize the '#{access}' access mode, using 'direct'."
        DirectRequest
      end
    end

    attr_reader :finder
    attr_reader :request
  end
end
