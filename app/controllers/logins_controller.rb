class LoginsController < ApplicationController
  def index
    @logins = current_customer.logins
  end

  def show
    @login    = Login.find(params[:id])
    @accounts = @login.accounts
  end

  def create_connection
    response    = SaltedgeClient.create_connection(current_customer.customer_id)
    connect_url = response.dig("data","connect_url")

    redirect_to connect_url
  rescue => error
    response = JSON.parse(error.response.body)
    flash.alert = response["error"]["message"]
    redirect_to logins_path
  end

  def destroy_login
    SaltedgeClient.remove_login(params[:login_id])
    Login.find_by(params[:login_id]).destroy

    redirect_to logins_path
  end

  def list
    logins = SaltedgeClient.fetch_logins(current_customer.customer_id)
    render json: logins
  end

  def success_callback
    save_login
    redirect_to logins_path
  end

  def save_login
    logins = SaltedgeClient.fetch_logins(current_customer.customer_id)

    login = Login.new(
      id:                       logins["data"].last["id"],
      customer_id:              logins["data"].last["customer_id"],
      provider_name:            logins["data"].last["provider_name"],
      country:                  logins["data"].last["country_code"],
      created_at:               logins["data"].last["created_at"],
      updated_at:               logins["data"].last["updated_at"],
      last_success_at:          logins["data"].last["last_success_at"],
      status:                   logins["data"].last["status"],
      next_refresh_possible_at: logins["data"].last["next_refresh_possible_at"]
    )
    login.save!

    fetch(login)
  end

  def reconnect_login
    response    = SaltedgeClient.reconnect_login(params[:login_id])
    connect_url = response.dig("data", "connect_url")

    flash.notice = "Login successfully reconnected"
    redirect_to connect_url
  rescue => error
    response = JSON.parse(error.response.body)
    flash.alert = response["error"]["message"]
    redirect_to logins_path
  end

  def refresh_login
    response    = SaltedgeClient.refresh_login(params[:login_id])
    connect_url = response.dig("data", "connect_url")

    flash.notice = "Login successfully refreshed"
    redirect_to connect_url
  rescue => error
    response = JSON.parse(error.response.body)
    flash.alert = response["error"]["message"]
    redirect_to logins_path
  end

  def remove_login
    SaltedgeClient.remove_login(params[:login_id])
    Login.find_by(login_id: params[:login_id]).destroy

    redirect_to logins_path
  end

  def fetch(login)
    login.accounts.destroy_all if login.accounts.any?

    fetch_accounts(login)
    fetch_transactions(login)
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
          category:       transaction_data["category"]
        )

        transaction.save!
      end
    end
  end
end
