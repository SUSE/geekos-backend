### Test openid connect
# #nonce = SecureRandom.hex(16)
# client = OicClient.new('https://backend.geekos.io/sessions/login')
# request_url = client.auth_uri(nonce)
## -> get browser redirect with 'code' param
# userinfo = client.validate(<code>, nonce)

# see also https://docs.openathens.net/display/public/OAAccess/Ruby+OpenID+Connect+example
# https://github.com/onelogin/onelogin-oidc-ruby/blob/master/1.%20Auth%20Flow/app/helpers/sessions_helper.rb
# Okta docs:
# https://developer.okta.com/docs/reference/api/oidc/

class OicClient
  def initialize(redirect_uri)
    @provider_uri = ENV['oic_provider_url']
    @client_id = ENV['oic_client_id']
    @secret = ENV['oic_secret']
    @redirect_uri = redirect_uri
  end

  # +nonce+ - Unique value associated with the request.
  # Same value needs to be passed to the #validate method (store in users session)
  def auth_uri(nonce)
    client.authorization_uri(
      scope: %i[profile email],
      state: nonce,
      nonce: nonce
    )
  end

  # * +code+ - The code returned from the OP after successful user authentication.
  # * +nonce+ - The same value use to call #auth_uri
  # (e.g read from the user session - <code>session.delete(:nonce)</code>)
  #
  # Returns the userinfo <code>OpenIDConnect::ResponseObject::UserInfo</code>.
  # Use <code>userinfo.raw_attributes</code> to access all the OpenId claims.
  def validate(code, nonce)
    client.authorization_code = code
    access_token = client.access_token!

    # https://github.com/nov/openid_connect/blob/master/lib/openid_connect/response_object/id_token.rb#L66
    # public_keys = config.jwks
    # id_token = OpenIDConnect::ResponseObject::IdToken.decode(access_token.id_token, public_keys)
    id_token = OpenIDConnect::ResponseObject::IdToken.new(JSON::JWT.decode(access_token.id_token, :skip_verification))
    id_token.verify!({ client_id: @client_id, issuer: config.issuer, nonce: nonce })

    access_token.userinfo!
  end

  private

  def client
    @client ||= OpenIDConnect::Client.new(
      identifier: @client_id,
      secret: @secret,
      redirect_uri: @redirect_uri,
      authorization_endpoint: config.authorization_endpoint,
      token_endpoint: config.token_endpoint,
      userinfo_endpoint: config.userinfo_endpoint
    )
  end

  def config
    @config ||= OpenIDConnect::Discovery::Provider::Config.discover! @provider_uri
  end
end
