require 'rails_helper'

RSpec.describe Login, type: :model do
  context "Login" do
    it "validates login_id presence" do
      customer = build(:login, login_id: nil)
      expect(customer.valid?).to eq(false)
      expect(customer.errors[:login_id]).to include("can't be blank")
    end
  end
end
