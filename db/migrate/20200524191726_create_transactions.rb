class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions, id: false do |t|
      t.bigint :transaction_id, primary_key: true
      t.string :status
      t.string :currency
      t.float :amount
      t.string :description
      t.string :made_on
      t.string :category
      t.string :mode
      t.belongs_to :account

      t.timestamps
    end
  end
end
