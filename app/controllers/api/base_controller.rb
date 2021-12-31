class Api::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :disable_session, :authenticate_user

  def current_user
    @current_user ||= nil
  end

  protected

  def disable_session
    request.session_options[:skip] = true
  end

  def authenticate_user
    @current_user = if (user = authenticate_with_http_token { |t, _| User.find_by(auth_token: t) })
                      user
                    end
  end

  def audit_log(&block)
    Mongoid::AuditLog.record(current_user, &block)
  end
end
