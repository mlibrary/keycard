# frozen_string_literal: true

class FakeUserModel
  def self.finder
  end
end

class FakeController
  include Keycard::ControllerMethods

  attr_reader :request, :notary, :session

  def initialize(request, session, notary)
    @request = request
    @session = session
    @notary = notary
  end

  def reset_session
    session.clear
  end
end
