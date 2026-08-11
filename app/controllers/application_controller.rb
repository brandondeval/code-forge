class ApplicationController < ActionController::Base
  private

  def current_user
    @current_user ||= user_from_token(request.headers["Authorization"]&.delete_prefix("Bearer "))
  end

  def require_user!
    render json: { error: "Authentication required" }, status: :unauthorized unless current_user
  end

  def user_from_token(token)
    payload = JsonWebToken.decode(token)
    User.find_by(id: payload[:sub]) if payload
  end
end
