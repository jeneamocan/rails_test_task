require 'rails_helper'

RSpec.describe Customer, type: :model do
  context "Customer" do
    it "validates email and password presence" do
      customer = build(:customer, email: nil, password: nil)
      expect(customer.valid?).to eq(false)
      expect(customer.errors[:email]).to include("can't be blank")
      expect(customer.errors[:password]).to include("can't be blank")
    end
  end
end
