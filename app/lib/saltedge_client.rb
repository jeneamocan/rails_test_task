require "rest-client"
require "json"
require 'active_support/all'

BASE_URL  = "https://www.saltedge.com/api/v5"
RETURN_TO = "https://salty-jenea.herokuapp.com/success"

class SaltedgeClient
  def self.create_customer(email)
    post("/customers", { "data" => { "identifier" => email } })
  end

  def self.create_connection(customer_id)
    post(
      "/connect_sessions/create",
      {
        "data" => {
          "customer_id" => customer_id,
          "consent"     => {
            "scopes"    => %w[account_details transactions_details],
            "from_date" => 365.days.ago.to_date.as_json
          },
          "attempt"     => {
            "return_to" => RETURN_TO
          }
        }
      }
    )
  end

  def self.refresh_login(login_id)
    put(
      "/connections/#{login_id}/refresh",
      {
        "data" => {
          "attempt" => {
            "fetch_scopes" => %w[accounts transactions]
          }
        }
      }
    )
  end

  def self.reconnect_login(login_id)
    post(
      "/connect_sessions/reconnect",
      {
        "data" => {
          "connection_id" => login_id,
          "consent"       => {
            "scopes" => %w[account_details transactions_details]
          },
          "attempt"       => {
            "fetch_scopes" => %w[accounts transactions],
            "return_to"    => RETURN_TO
          }
        }
      }
    )
  end

  def self.destroy_login(login_id)
    delete("/connections/#{login_id}")
  end

  def self.fetch_logins(customer_id)
    get("/connections?customer_id=#{customer_id}")
  end

  def self.fetch_accounts(login)
    get("/accounts?connection_id=#{login.id}&customer_id=#{login.customer_id}")
  end

  def self.fetch_transactions(account)
    get("/transactions?connection_id=#{account.connection_id}&account_id=#{account.id}")
  end

  private

  def self.get(url, payload = {})
    request(method: :get, url: BASE_URL + url, payload: payload.to_json)
  end

  def self.post(url, payload = {})
    request(method: :post, url: BASE_URL + url, payload: payload.to_json)
  end

  def self.put(url, payload = {})
    request(method: :put, url: BASE_URL + url, payload: payload.to_json)
  end

  def self.delete(url, payload = {})
    request(method: :delete, url: BASE_URL + url, payload: payload.to_json)
  end

  def self.request(options)
    options[:headers] ||= {}
    options[:headers].reverse_merge!(
      "Accept":       "application/json",
      "Content-type": "application/json",
      "App-id":       Settings.application.app_id,
      "Secret":       Settings.application.secret
    )

    response = RestClient::Request.execute(options)
    JSON.parse(response)
  end
end
