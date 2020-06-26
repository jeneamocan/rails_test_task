require 'rails_helper'

RSpec.describe Transaction, type: :model do
  context "Transaction" do
    it "validates transaction_id presence" do
      customer = build(:transaction, transaction_id: nil)
      expect(customer.valid?).to eq(false)
      expect(customer.errors[:transaction_id]).to include("can't be blank")
    end
  end
end
