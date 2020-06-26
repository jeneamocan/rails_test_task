class LoginsController < ApplicationController
  add_breadcrumb "Connections", :logins_path

  def index
    @logins = current_customer.logins
  end

  def show
    @login    = Login.find(params[:login_id])
    @accounts = @login.accounts
  end

  def create
    response    = SaltedgeClient.create_connection(current_customer.customer_id)
    connect_url = response.dig("data","connect_url")

    redirect_to connect_url
  rescue => error
    handle_error(error)
  end

  def reconnect
    response    = SaltedgeClient.reconnect(params[:login_id])
    connect_url = response.dig("data", "connect_url")

    redirect_to connect_url
  rescue => error
    handle_error(error)
  end

  def refresh
    login = Login.find(params[:login_id])

    if login.next_refresh_possible_at < Time.current.to_datetime
      response    = SaltedgeClient.refresh(login.login_id)
      connect_url = response.dig("data", "connect_url")

      redirect_to connect_url
    else
      flash.notice = "Next refresh will be possible at #{login.next_refresh_possible_at.strftime("%Y/%m/%d %H:%M:%S")}"
      redirect_to logins_path
    end
  rescue => error
    handle_error(error)
  end

  def destroy
    SaltedgeClient.destroy(params[:login_id])
    Login.find(params[:login_id]).destroy

    redirect_to logins_path
  end

  def success
    handle_callback
    redirect_to logins_path
  end

  private

  def handle_callback
    response = SaltedgeClient.fetch_connections(current_customer.customer_id)

    login = create_or_update_login(response)
    login.fetch
  end

  def create_or_update_login(response)
    updated_login  = response.fetch("data").max_by { |connection| connection["updated_at"].to_datetime }
    existing_login = Login.find_by(login_id: updated_login.fetch("id"))

    if existing_login
      login = existing_login
      login.update!(
        status:                   updated_login.fetch("status"),
        last_success_at:          updated_login.fetch("last_success_at"),
        next_refresh_possible_at: updated_login.fetch("next_refresh_possible_at")
      )
    else
      login = Login.create(
        login_id:                 updated_login.fetch("id"),
        customer_id:              updated_login.fetch("customer_id"),
        provider_name:            updated_login.fetch("provider_name"),
        country_code:             updated_login.fetch("country_code"),
        status:                   updated_login.fetch("status"),
        last_success_at:          updated_login.fetch("last_success_at"),
        next_refresh_possible_at: updated_login.fetch("next_refresh_possible_at")
      )
      login.save!
    end

    login
  end

  def handle_error(error)
    if error.try(:response).try(:body)
      response = JSON.parse(error.response.body)
      flash.alert = response["error"]["message"]
    else
      flash.alert = "Something went wrong"
    end

    redirect_to logins_path
  end
end
