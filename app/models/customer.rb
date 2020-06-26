class Customer < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :logins, primary_key: "customer_id"

  validates :email, presence: true
end
