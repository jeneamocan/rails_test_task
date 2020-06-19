FactoryBot.define do

  factory :transaction do
    transaction_id { 1 }
    account_id { 1 }
    status { "posted" }
    currency { "EUR" }
    amount { 49.0 }
    description { "Description" }
    made_on { "2020-05-05" }
    category { "services" }
    mode { "normal" }
  end

  factory :login do
    login_id { 1 }
    customer_id { 1 }
    status { "active" }
    country_code { "XF" }
    provider_name { "Fake Provider" }
    updated_at { "2020-05-05T00:00:00+00:00" }
    next_refresh_possible_at { "2020-06-06T00:00:00+00:00" }
  end

  factory :account do
    account_id { 1 }
    login_id { 1 }
    name { "Test account" }
    balance { 49.0 }
    currency { "EUR" }
    transactions_count { 10 }
  end

  factory :customer do
    customer_id { 1 }
    username { "Eugen" }
    password { "123456" }
    email { "specs@gmail.com" }
    encrypted_password { "123" }
    reset_password_token { "321" }
    reset_password_sent_at { "2020-05-05T00:00:00+00:00" }
    remember_created_at { "2020-05-05T00:00:00+00:00" }
  end
end