# frozen_string_literal: true

require "keycard/request/shibboleth_attributes"

RSpec.describe Keycard::Request::ShibbolethAttributes do
  context "with headers via Shibboleth" do
    let(:request) do
      double('request', env: {
        'HTTP_X_SHIB_EDUPERSONPRINCIPALNAME' => 'someuser@default.invalid',
        'HTTP_X_SHIB_EDUPERSONSCOPEDAFFILIATION' => 'member@default.invalid;staff@default.invalid',
        'HTTP_X_SHIB_DISPLAYNAME' => 'Aardvark Jones',
        'HTTP_X_SHIB_MAIL' => 'someuser@mail.default.invalid',
        'HTTP_X_SHIB_PERSISTENT_ID' => 'https://idp.default.invalid/shib/idp!https://sp.default.invalid/shib/sp!asfgkjhlk',
        'HTTP_X_SHIB_AUTHENTICATION_METHOD' => 'urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport',
        'HTTP_X_SHIB_AUTHNCONTEXT_CLASS' => 'urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport',
        'HTTP_X_SHIB_IDENTITY_PROVIDER' => 'https://idp.default.invalid/shib/idp'
       })
    end

    let(:attributes) { described_class.new(request) }

    it "uses the Persistent NameID for the user_pid" do
      expect(attributes.user_pid).to eq(
        'https://idp.default.invalid/shib/idp!https://sp.default.invalid/shib/sp!asfgkjhlk'
      )
    end

    it "uses the eduPersonPrincipalName for the user_eid" do
      expect(attributes.user_eid).to eq 'someuser@default.invalid'
    end

    describe '#all' do
      it "includes displayName" do
        expect(attributes[:displayName]).to eq 'Aardvark Jones'
      end

      it "includes displayName" do
        expect(attributes[:eduPersonScopedAffiliation]).to contain_exactly(
          'member@default.invalid', 'staff@default.invalid'
        )
      end
    end
  end

  context "with no forwarded headers" do
    let(:request)    { double('request', env: {}) }
    let(:attributes) { described_class.new(request) }

    it "the user_pid is empty" do
      expect(attributes.user_pid).to eq ''
    end

    it "the user_eid is empty" do
      expect(attributes.user_eid).to eq ''
    end

    it "the client_ip is empty" do
      expect(attributes.client_ip).to eq ''
    end
  end

  context "with multiple forwarded addresses" do
    let(:request) do
      double('request', env: {
               'HTTP_X_FORWARDED_FOR' => '10.0.0.2, 10.0.0.1'
             })
    end
    let(:attributes) { described_class.new(request) }

    it "extracts the first address" do
      expect(attributes.client_ip).to eq '10.0.0.2'
    end
  end
end
