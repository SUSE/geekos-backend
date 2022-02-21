class SessionsController < ApplicationController
  def init
    session[:nonce] = SecureRandom.hex(16)
    session[:frontend_url] = params['frontend_url']
    client = OicClient.new(sessions_login_url)
    request_url = client.auth_uri(session[:nonce])
    redirect_to(request_url, allow_other_host: true)
  end

  def login
    client = OicClient.new(sessions_login_url)
    userinfo = client.validate(params[:code], session[:nonce])
    user = ::User.find_by('ldap.mail': /^#{userinfo.email}$/i)
    if user
      logger.info("Successful login from #{user.username}")
      auth_token = user.auth_token
    else
      logger.error("Failed login from #{userinfo.email}: User not found")
    end
    redirect_to((session[:frontend_url] || '/') + "?auth_token=#{auth_token}")
  end
end
