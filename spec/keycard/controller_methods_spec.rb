# frozen_string_literal: true

RSpec.describe Keycard::ControllerMethods do
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

    def session_timeout
      60
    end
  end

  subject(:controller) { FakeController.new(request, session, notary) }

  let(:request) { OpenStruct.new(env: {}) }
  let(:session) { { timestamp: Time.now } }

  before(:each) do
    allow(notary).to receive(:waive) do |account|
      double("Certificate", authenticated?: true, failed?: false, account: account)
    end

    allow(notary).to receive(:reject).and_return(
      double("Certificate", authenticated?: false, failed?: true, account: nil)
    )
  end

  context "with successful authentication" do
    let(:account)     { double("User", id: 1) }
    let(:certificate) { double("Certificate", authenticated?: true, failed?: false, account: account) }
    let(:notary)      { double("Notary", authenticate: certificate) }

    it "reports that the user is logged in" do
      expect(controller.logged_in?).to eq true
    end

    it "sets the current user" do
      expect(controller.current_user).to eq(account)
    end

    it "does not raise from the authenticate! before_action" do
      expect { controller.authenticate! }.not_to raise_error
    end

    it "resets the session when logging in" do
      session[:foo] = "bar"
      controller.login
      expect(session[:foo]).to be_nil
    end

    it "sets the session user_id when logging in" do
      controller.login
      expect(session[:user_id]).to eq 1
    end

    it "sets the session timestamp when logging in" do
      controller.login
      expect(Time.now - session[:timestamp]).to be <= 1
    end

    it "preserves the :return_to URL in session when logging in" do
      session[:return_to] = "/some/url"
      controller.login
      expect(session[:return_to]).to eq "/some/url"
    end

    it "disregards authentication when doing an auto-login" do
      user = double("User", id: 2)
      controller.auto_login(user)
      expect(controller.current_user).to eq user
    end

    it "sets the session user_id when doing auto-login" do
      user = double("User", id: 2)
      controller.auto_login(user)
      expect(session[:user_id]).to eq 2
    end

    it "sets the session timestamp when logging in" do
      user = double("User", id: 2)
      controller.auto_login(user)
      expect(Time.now - session[:timestamp]).to be <= 1
    end

    it "clears the current_user when doing logout" do
      controller.login
      controller.logout
      expect(controller.current_user).to be_nil
    end

    it "clears the session user_id when doing logout" do
      controller.login
      controller.logout
      expect(session[:user_id]).to be_nil
    end
  end

  context "with failed authentication" do
    let(:certificate) { double("Certificate", authenticated?: false, failed?: true, account: nil) }
    let(:notary)      { double("Notary", authenticate: certificate) }

    it "reports that the user is not logged in" do
      expect(controller.logged_in?).to eq false
    end

    it "does not have a current_user" do
      expect(controller.current_user).to be_nil
    end

    it "does not set a session user_id" do
      expect(session[:user_id]).to be_nil
    end

    it "raises AuthenticationFailed when calling the authenticate! before_action" do
      expect { controller.authenticate! }.to raise_error(Keycard::AuthenticationFailed)
    end
  end

  context "with missing authentication" do
    let(:account)     { double("User", id: 1) }
    let(:certificate) { double("Certificate", authenticated?: false, failed?: false, account: nil) }
    let(:notary)      { double("Notary", authenticate: certificate) }

    it "reports that the user is not logged in" do
      expect(controller.logged_in?).to eq false
    end

    it "does not have a current_user" do
      expect(controller.current_user).to be_nil
    end

    it "does not set a session user_id" do
      expect(session[:user_id]).to be_nil
    end

    it "raises AuthenticationRequired when calling the authenticate! before_action" do
      expect { controller.authenticate! }.to raise_error(Keycard::AuthenticationRequired)
    end

    it "has a current_user after auto-login" do
      controller.auto_login(account)
      expect(controller.current_user).to eq account
    end

    it "sets the session user_id when doing auto-login" do
      controller.auto_login(account)
      expect(session[:user_id]).to eq 1
    end
  end

  context "with an expired or nonexistent session" do
    let(:notary) { double("Notary") }

    it "resets the session when validating" do
      session[:timestamp] = Time.now - 1000
      session[:something] = "value"
      controller.validate_session

      expect(session).not_to include(:something)
    end

    it "preserves a CSRF token for login workflows" do
      session[:timestamp] = nil
      session[:_csrf_token] = "abcd"
      controller.validate_session

      expect(session[:_csrf_token]).to eq "abcd"
    end
  end

  context "with a current session" do
    let(:notary) { double("Notary") }

    it "does not reset the session when validating" do
      session[:timestamp] = Time.now - 5
      session[:something] = "value"
      controller.validate_session

      expect(session[:something]).to eq "value"
    end
  end

  # This example group verifies that user-supplied credentials are passed along
  # to the Notary properly. To use this would require a custom verification
  # that inspects the keyword arguments appropriately for the credentials.
  context "with user-supplied credentials for login and corresponding verification method" do
    let(:account) { double("User", id: 1) }
    let(:failure) { double("Certificate", authenticated?: false, failed?: true, account: nil) }
    let(:success) { double("Certificate", authenticated?: true, failed?: false, account: account) }
    let(:notary)  { double("Notary") }

    before(:each) do
      allow(notary).to receive(:authenticate) do |_request, _session, **credentials|
        if credentials[:username] == "user" && credentials[:password] == "secret"
          success
        else
          failure
        end
      end
    end

    it "logs the user in with good credentials" do
      controller.login(username: "user", password: "secret")
      expect(controller.current_user).to eq account
    end

    it "fails for bad credentials" do
      controller.login(username: "foo", password: "bar")
      expect(controller.current_user).to be_nil
    end
  end
end
