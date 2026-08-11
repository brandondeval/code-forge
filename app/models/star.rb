class Star < ApplicationRecord
  belongs_to :user
  belongs_to :repository, counter_cache: :stars_count
  validates :user_id, uniqueness: { scope: :repository_id }
end
