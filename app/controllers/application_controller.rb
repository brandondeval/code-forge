class ApplicationController < ActionController::Base
  private

  def current_user
    @current_user ||= user_from_token(bearer_token || cookies.encrypted[:forge_access_token])
  end

  def require_user!
    render json: { error: "Authentication required" }, status: :unauthorized unless current_user
  end

  def user_from_token(token)
    payload = JsonWebToken.decode(token)
    User.find_by(id: payload[:sub]) if payload
  end

  def bearer_token
    request.headers["Authorization"]&.match(/\ABearer (.+)\z/)&.captures&.first
  end
end
