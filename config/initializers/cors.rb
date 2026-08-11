Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://localhost:5173"
    resource "/api/*", headers: :any, methods: %i[get post patch delete options]
    resource "/oauth/*", headers: :any, methods: %i[post options]
  end
end
