class Issue < ApplicationRecord
  belongs_to :repository
  belongs_to :author, class_name: "User"
  enum :state, { open: "open", closed: "closed" }, default: :open
  validates :title, presence: true
end
