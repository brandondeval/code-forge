class JsonWebToken
  ALGORITHM = "HS256"

  def self.encode(user)
    JWT.encode({ sub: user.id, login: user.login, exp: 24.hours.from_now.to_i }, secret, ALGORITHM)
  end

  def self.decode(token)
    JWT.decode(token, secret, true, algorithm: ALGORITHM).first.with_indifferent_access
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def self.secret
    ENV.fetch("JWT_SECRET", "development-only-change-this-secret")
  end
end
