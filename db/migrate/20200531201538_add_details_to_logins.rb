class AddDetailsToLogins < ActiveRecord::Migration[6.0]
  def change
    add_column :logins, :login_id, :bigint
    add_column :logins, :provider_name, :string
    add_column :logins, :customer_identifier, :string
    add_reference :logins, :customer, foreign_key: "customer_id"
  end
end
