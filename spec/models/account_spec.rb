require 'rails_helper'

RSpec.describe Account, type: :model do
  context "Account" do
    it "validates account_id presence" do
      account = build(:account, account_id: nil)
      expect(account.valid?).to eq(false)
      expect(account.errors[:account_id]).to include("can't be blank")
    end

    it "validates existance of login" do
      account = build(:account)
      expect(account.valid?).to eq(false)
      expect(account.errors[:login]).to include("must exist")
    end
  end
end
