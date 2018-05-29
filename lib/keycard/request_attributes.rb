# frozen_string_literal: true

module Keycard
  # This class is responsible for extracting the user attributes (i.e. the
  # complete set of things that determine the user's #identity), given a Rack
  # request.
  class RequestAttributes
    def initialize(request, finder: InstitutionFinder.new, request_factory: default_factory)
      @request  = request
      @finder   = finder
      @request_factory = request_factory
    end

    def [](attr)
      all[attr]
    end

    def all
      user_attributes.merge(finder.attributes_for(request))
    end

    private

    def user_attributes
      { username: request.username }
    end

    def request
      request_factory.for(@request)
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
    attr_reader :request_factory
  end
end
