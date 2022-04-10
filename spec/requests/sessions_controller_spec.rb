require 'rails_helper'

describe '/sessions', type: 'request' do
  let(:frontend_url) { 'http://geekos.scc.suse.de' }

  describe '#init' do
    subject(:oic_init_request) { get sessions_init_url, params: { frontend_url: } }

    context 'with frontend_url' do
      it 'redirects to the frontend with auth token parameter' do
        allow_any_instance_of(OicClient).to receive(:auth_uri).and_return('https://localhost')
        expect(oic_init_request).to eq 302
      end
    end
  end

  describe '#login' do
    subject(:oic_login_request) { get sessions_login_url, params: { code: oic_response } }

    context 'with an invalid oic response' do
      let(:oic_response) { '123' }

      it 'raises validation error' do
        allow_any_instance_of(OicClient).to receive(:validate).and_raise(Rack::OAuth2::Client::Error.new(500, {}))

        expect { oic_login_request }.to raise_error(Rack::OAuth2::Client::Error)
      end
    end

    context 'with a valid oic response' do
      let(:oic_response) { '123' }
      let(:userinfo) { instance_double('OpenIDConnect::ResponseObject::UserInfo') }
      let(:user) { create(:user, :ldap) }

      it 'redirects to the frontend with auth token parameter' do
        allow_any_instance_of(OicClient).to receive(:validate).and_return(userinfo)
        allow(userinfo).to receive(:email).and_return(user.email)

        expect(oic_login_request).to redirect_to("/?auth_token=#{user.auth_token}")
      end

      it 'redirects to the frontend without auth token if user not found' do
        allow_any_instance_of(OicClient).to receive(:validate).and_return(userinfo)
        allow(userinfo).to receive(:email).and_return('no')

        expect(oic_login_request).to redirect_to('/?auth_token=')
      end
    end
  end
end
