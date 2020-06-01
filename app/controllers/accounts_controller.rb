class AccountsController < ApplicationController
  def fetch
    login = Login.find_by(login_id: params[:login_id])
    login.accounts.destroy_all if login.accounts.any?

    fetch_accounts(login)
    fetch_transactions(login)

    redirect_to login
  end

  def fetch_accounts(login)
    response = SaltedgeClient.fetch_accounts(login)
    response.fetch("data").each do |account_data|
      posted_count  = account_data.dig("extra", "transactions_count", "posted").to_i
      pending_count = account_data.dig("extra", "transactions_count", "pending").to_i

      account = Account.new(
        account_id:         account_data["id"],
        connection_id:      account_data["connection_id"],
        name:               account_data["name"],
        balance:            account_data["balance"],
        currency:           account_data["currency_code"],
        nature:             account_data["nature"],
        transactions_count: transactions_posted + transactions_pending
      )

      account.save!
    end
  end

  def fetch_transactions(login)
    login.accounts.each do |account|
      response     = SaltedgeClient.fetch_transactions(account)
      response.fetch("data").each do |transaction_data|
        transaction = Transaction.new(
          transaction_id: transaction_data["id"],
          account_id:     transaction_data["account_id"],
          status:         transaction_data["status"],
          currency:       transaction_data["currency_code"],
          amount:         transaction_data["amount"],
          description:    transaction_data["description"],
          made_on:        transaction_data["made_on"],
          category:       transaction_data["category"],
        )

        transaction.save!
      end
    end
  end

  def show
    @account      = Account.find(params[:id])
    @transactions = @account.transactions
  end
end
