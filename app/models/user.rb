class User < ApplicationRecord
  has_many :repositories, foreign_key: :owner_id, dependent: :destroy
  has_many :issues, foreign_key: :author_id, dependent: :nullify
  has_many :pull_requests, foreign_key: :author_id, dependent: :nullify
  has_many :stars, dependent: :destroy
  has_many :starred_repositories, through: :stars, source: :repository
  validates :login, presence: true, uniqueness: true
  has_secure_password
  validates :email, uniqueness: true, allow_blank: true
end
