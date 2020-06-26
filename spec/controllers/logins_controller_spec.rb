require 'rails_helper'
require 'spec_helper'

URL = "https://www.saltedge.com/connect"

RSpec.describe LoginsController, type: :controller do
  let(:customer)    { create(:customer) }
  let(:login)       { build(:login) }
  let(:account)     { build(:account) }
  let(:transaction) { build(:transaction) }

  before :each do
    sign_in customer

    allow(Login)
      .to receive(:where)
      .and_return(login)

    allow_any_instance_of(Login)
      .to receive(:save!)
      .and_return(true)
  end

  describe "#create" do
    it "creates a new connection" do
      expect(SaltedgeClient)
        .to receive(:create_connection).once
        .and_return("data" => { "connect_url" => URL })

      post :create

      expect(response).to redirect_to(URL)
    end
  end

  describe "#refresh" do
    it "refreshes a connection" do
      Timecop.freeze(2020, 06, 07) do
        allow(Login).to receive(:find).and_return(login)

        expect(SaltedgeClient)
          .to receive(:refresh).once
          .and_return("data" => { "connect_url" => URL })

        post :refresh, params: { login_id: login.login_id }

        expect(response).to redirect_to(URL)
      end
    end

    it "denies refresh if refresh is not yet possible" do
      Timecop.freeze(2020, 06, 05) do
        allow(Login).to receive(:find).and_return(login)

        post :refresh, params: { login_id: login.login_id }

        expect(response).to redirect_to(logins_url)
        expect(flash.notice).to match("Next refresh will be possible at 2020/06/06 00:00:00")
      end
    end
  end

  describe "#reconnect" do
    it "reconnects a connection" do
      expect(SaltedgeClient)
        .to receive(:reconnect).once
        .and_return("data" => { "connect_url" => URL })

      post :reconnect, params: { login_id: login.login_id }

      expect(response).to redirect_to(URL)
    end
  end

  describe "#handle_callback" do
    it "handles success callback and fetched account information" do
      logins = {
        "data" => [
          {
            "id"                       => 1,
            "customer_id"              => 1,
            "country_code"             => "XF",
            "provider_name"            => "Fake Demo Bank",
            "created_at"               => "2020-06-16T20:49:11Z",
            "updated_at"               => "2020-06-16T20:49:21Z",
            "last_success_at"          => "2020-06-16T20:49:21Z",
            "next_refresh_possible_at" => "2020-06-16T21:04:21Z",
            "status"                   => "active"
          }
        ]
      }

      accounts = {
        "data"=> [
          {
            "id"            => 1,
            "connection_id" => 1,
            "name"          => "Test account",
            "nature"        => "account",
            "balance"       => 40.0,
            "currency_code" => "EUR",
            "extra"         => {
              "transactions_count" => {
                "posted"  => 1,
                "pending" => 0
              }
            }
          }
        ]
      }

      transactions = {
        "data" => [
          {
            "id"            => 1,
            "account_id"    => 1,
            "status"        => "posted",
            "currency_code" => "EUR",
            "amount"        => 10.0,
            "description"   => "transaction",
            "made_on"       => "2019-10-10",
            "category"      => "expenses",
          }
        ]
      }

      expect(SaltedgeClient)
        .to receive(:fetch_connections)
        .with(customer.customer_id)
        .and_return(logins)

      allow(Login).to receive(:find_by).and_return(nil)

      expect(SaltedgeClient)
        .to receive(:fetch_accounts)
        .with(login)
        .and_return(accounts)

      expect(SaltedgeClient)
        .to receive(:fetch_transactions)
        .with(account)
        .and_return(transactions)

      controller.send(:handle_callback)

      expect(login.accounts.size).to eq(1)
      expect(login.accounts.first.transactions.size).to eq(1)
    end
  end

  describe "#handle_errors" do
    it "handles http errors" do
      error = RestClient::ExceptionWithResponse.new(
        RestClient::Response.new({ "error" => { "message" => "Connection cannot be refreshed" } }.to_json)
      )

      expect(SaltedgeClient)
        .to receive(:reconnect).once
        .and_raise(error)

      post :reconnect, params: { login_id: login.login_id }

      expect(response).to redirect_to(logins_url)
      expect(flash.alert).to match("Connection cannot be refreshed")
    end

    it "handles unexpected errors" do
      allow(Login).to receive(:find).and_return(login)

      expect(SaltedgeClient)
        .to receive(:reconnect).once
        .and_raise(RestClient::Exception)

      post :reconnect, params: { login_id: login.login_id }

      expect(response).to redirect_to(logins_url)
      expect(flash.alert).to match("Something went wrong")
    end
  end
end
