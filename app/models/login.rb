class Login < ApplicationRecord
  belongs_to :customer, foreign_key: "customer_id"
  has_many :accounts, dependent: :destroy

  validates :login_id, uniqueness: true
end
