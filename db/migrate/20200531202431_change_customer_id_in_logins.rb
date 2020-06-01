class ChangeCustomerIdInLogins < ActiveRecord::Migration[6.0]
  def change
    change_column :customers, :customer_id, :integer
  end
end
