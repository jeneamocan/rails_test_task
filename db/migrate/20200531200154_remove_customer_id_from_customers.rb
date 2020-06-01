class RemoveCustomerIdFromCustomers < ActiveRecord::Migration[6.0]
  def change
    remove_column :customers, :client_id, :string
  end
end
