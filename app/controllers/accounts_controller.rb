class AccountsController < ApplicationController
  add_breadcrumb "Connections", :logins_path

  def show
    @account      = Account.find(params[:account_id])
    @transactions = @account.transactions
  end
end
