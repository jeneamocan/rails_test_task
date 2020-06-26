class Login < ApplicationRecord
  belongs_to :customer
  has_many :accounts, primary_key: "login_id", dependent: :destroy

  validates :login_id, uniqueness: true, presence: true

  def fetch
    fetch_accounts
    fetch_transactions
  end

  private

  def fetch_accounts
    self.accounts.destroy_all if self.accounts.any?

    response = SaltedgeClient.fetch_accounts(self)
    response.fetch("data").each do |account_data|
      posted_count  = account_data.dig("extra", "transactions_count", "posted").to_i
      pending_count = account_data.dig("extra", "transactions_count", "pending").to_i

      account = Account.new(
        account_id:         account_data.fetch("id"),
        login_id:           account_data.fetch("connection_id"),
        name:               account_data.fetch("name"),
        balance:            account_data.fetch("balance"),
        currency:           account_data.fetch("currency_code"),
        nature:             account_data.fetch("nature"),
        transactions_count: posted_count + pending_count
      )

      account.save!
    end
  end

  def fetch_transactions
    self.accounts.each do |account|
      response     = SaltedgeClient.fetch_transactions(account)
      response.fetch("data").each do |transaction_data|
        transaction = Transaction.new(
          transaction_id: transaction_data.fetch("id"),
          account_id:     transaction_data.fetch("account_id"),
          status:         transaction_data.fetch("status"),
          currency:       transaction_data.fetch("currency_code"),
          amount:         transaction_data.fetch("amount"),
          description:    transaction_data.fetch("description"),
          made_on:        transaction_data.fetch("made_on"),
          category:       transaction_data.fetch("category")
        )

        transaction.save!
      end
    end
  end
end
