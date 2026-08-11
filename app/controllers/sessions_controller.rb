class SessionsController < ApplicationController
  skip_forgery_protection

  def register
    user = User.new(registration_params)
    if user.save
      render json: token_response(user), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # OAuth-style password grant for local development. Clients exchange their
  # credentials for a short-lived JWT bearer token.
  def create
    user = User.find_by(login: params[:login]) || User.find_by(email: params[:login])
    if user&.authenticate(params[:password])
      render json: token_response(user)
    else
      render json: { error: "Invalid login or password" }, status: :unauthorized
    end
  end

  # Local development-only reset flow. Replace with a verified email/token flow
  # before exposing this endpoint outside a trusted environment.
  def forgot_password
    user = User.find_by(login: params[:login]) || User.find_by(email: params[:login])
    return render(json: { error: "Account not found" }, status: :not_found) unless user

    if user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      render json: { message: "Password updated. You can now sign in." }
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:login, :email, :password, :password_confirmation)
  end

  def token_response(user)
    { access_token: JsonWebToken.encode(user), token_type: "Bearer", expires_in: 24.hours.to_i, user: user.slice(:id, :login, :email) }
  end
end
