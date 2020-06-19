class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts, id: false do |t|
      t.bigint :account_id, primary_key: true
      t.string :name
      t.float :balance
      t.string :currency
      t.string :nature
      t.integer :transactions_count
      t.belongs_to :login

      t.timestamps
    end
  end
end
