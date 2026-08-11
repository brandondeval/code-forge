class Api::V1::BaseController < ApplicationController
  # API requests authenticate with an Authorization bearer token rather than a
  # browser session cookie, so Rails' form CSRF token does not apply here.
  skip_forgery_protection
end
