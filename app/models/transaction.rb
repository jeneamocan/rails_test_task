class Transaction < ApplicationRecord
  belongs_to :account

  validates :transaction_id, uniqueness: true
end
