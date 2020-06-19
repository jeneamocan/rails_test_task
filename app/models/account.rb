class Account < ApplicationRecord
  belongs_to :login
  has_many :transactions, primary_key: "account_id", dependent: :destroy

  validates :account_id, uniqueness: true, presence: true
end
