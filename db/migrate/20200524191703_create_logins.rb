class CreateLogins < ActiveRecord::Migration[6.0]
  def change
    create_table :logins, id: false do |t|
      t.bigint :login_id, primary_key: true
      t.string :status
      t.string :country_code
      t.string :provider_name
      t.datetime :last_success_at
      t.datetime :next_refresh_possible_at
      t.belongs_to :customer
      t.timestamps
    end
  end
end
