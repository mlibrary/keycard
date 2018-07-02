# frozen_string_literal: true

require "keycard/proxied_request"

RSpec.describe Keycard::ProxiedRequest do
  context "with typical forwarded headers" do
    let(:base) do
      double('base request', env: {
               'HTTP_X_REMOTE_USER' => 'user',
               'HTTP_X_FORWARDED_FOR' => '10.0.0.1'
             })
    end
    let(:request) { described_class.new(base) }

    it "extracts the username from HTTP_X_REMOTE_USER" do
      expect(request.username).to eq 'user'
    end

    it "extracts the client IP address from HTTP_X_FORWARDED_FOR" do
      expect(request.client_ip).to eq '10.0.0.1'
    end
  end

  context "with no forwarded headers" do
    let(:base)    { double('base request', env: {}) }
    let(:request) { described_class.new(base) }

    it "the username is empty" do
      expect(request.username).to eq ''
    end

    it "the client_ip is empty" do
      expect(request.client_ip).to eq ''
    end
  end

  context "with multiple forwarded addresses" do
    let(:base) do
      double('base request', env: {
               'HTTP_X_FORWARDED_FOR' => '10.0.0.2, 10.0.0.1'
             })
    end
    let(:request) { described_class.new(base) }

    it "extracts the first address" do
      expect(request.client_ip).to eq '10.0.0.2'
    end
  end

#  context "with headers via shibboleth" do
#    let(:base) do
#      double('base request', env: {
#        'HTTP_X_SHIB_EDUPERSONPRINCIPALNAME' => 'someuser@default.invalid',
#        'HTTP_X_SHIB_EDUPERSONSCOPEDAFFILIATION' => 'member@default.invalid;staff@default.invalid',
#        'HTTP_X_SHIB_DISPLAYNAME' => 'Aardvark Jones',
#        'HTTP_X_SHIB_MAIL' => 'someuser@mail.default.invalid',
#        'HTTP_X_SHIB_PERSISTENT_ID' => 'https://idp.default.invalid/shib/idp!https://sp.default.invalid/shib/sp!asfgkjhlk',
#        'HTTP_X_SHIB_AUTHENTICATION_METHOD' => 'urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport',
#        'HTTP_X_SHIB_AUTHNCONTEXT_CLASS' => 'urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport',
#        'HTTP_X_SHIB_IDENTITY_PROVIDER' => 'https://idp.default.invalid/shib/idp'
#       })
#    end
#
#    let(:request) { described_class.new(base) }
#
#  end

  describe "#for" do
    let(:base)    { double('base request', env: {}) }
    let(:request) { described_class.for(base) }

    it "gives a ProxiedRequest" do
      expect(request).to be_a Keycard::ProxiedRequest
    end
  end
end
