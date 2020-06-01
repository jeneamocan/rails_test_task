class ChangeClientUsersToCustomers < ActiveRecord::Migration[6.0]
  def change
    rename_table :client_users, :customers
  end
end
