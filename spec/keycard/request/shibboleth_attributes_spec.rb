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
               'HTTP_X_SHIB_IDENTITY_PROVIDER' => 'https://idp.default.invalid/shib/idp',
               'HTTP_X_FORWARDED_FOR' => '10.0.0.1'
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

    it "uses the mail for email" do
      expect(attributes.email).to eq 'someuser@mail.default.invalid'
    end

    it "uses the displayName for display_name" do
      expect(attributes.display_name).to eq 'Aardvark Jones'
    end

    it "uses the eduPersonScopedAffiliation for affiliation" do
      expect(attributes.affiliation).to eq(['member@default.invalid', 'staff@default.invalid'])
    end

    it "uses the auth context as method" do
      expect(attributes.authn_method).to eq 'urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport'
    end

    it "uses the identity provider URL as identity_provider" do
      expect(attributes.identity_provider).to eq 'https://idp.default.invalid/shib/idp'
    end

    it "uses the forwarded for header as client_ip" do
      expect(attributes.client_ip).to eq '10.0.0.1'
    end

    describe '#all' do
      it "includes user_pid" do
        expect(attributes[:user_pid]).not_to be_nil
      end

      it "includes user_eid" do
        expect(attributes[:user_eid]).not_to be_nil
      end

      it "includes client_ip" do
        expect(attributes[:client_ip]).not_to be_nil
      end

      it "includes identity_provider" do
        expect(attributes[:identity_provider]).not_to be_nil
      end

      it "includes persistentNameID" do
        expect(attributes[:persistentNameID]).not_to be_nil
      end

      it "includes eduPersonPrincipalName" do
        expect(attributes[:eduPersonPrincipalName]).not_to be_nil
      end

      it "includes eduPersonScopedAffiliation" do
        expect(attributes[:eduPersonScopedAffiliation]).not_to be_nil
      end

      it "includes mail" do
        expect(attributes[:mail]).not_to be_nil
      end

      it "includes authnContextClassRef" do
        expect(attributes[:authnContextClassRef]).not_to be_nil
      end

      it "includes authenticationMethod" do
        expect(attributes[:authenticationMethod]).not_to be_nil
      end
    end

    describe "#identity" do
      it "includes only user_pid, user_eid and affiliation" do
        expect(attributes.identity.keys).to contain_exactly(:user_pid, :user_eid, :eduPersonScopedAffiliation)
      end
    end
  end

  context "with no forwarded headers" do
    let(:request)    { double('request', env: {}) }
    let(:attributes) { described_class.new(request) }

    it "the user_pid is empty" do
      expect(attributes.user_pid).to be_nil
    end

    it "the user_eid is empty" do
      expect(attributes.user_eid).to be_nil
    end

    it "the client_ip is empty" do
      expect(attributes.client_ip).to be_nil
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
