require 'rails_helper'

RSpec.describe SaltedgeClient do
  let(:response) do
    { code: 200, headers: {}, body: "\"data\"=>{}" }
  end

  describe "#get" do
    it "calls a GET request" do
      expect(described_class)
        .to receive(:request)
        .with(hash_including(method: :get, url: BASE_URL + "/connections"))
        .and_return(response)

      expect(described_class.get("/connections")).to eq(response)
    end
  end

  describe "#post" do
    it "calls a POST request" do
      expect(described_class)
        .to receive(:request)
        .with(hash_including(method: :post, url: BASE_URL + "/connections"))
        .and_return(response)

      expect(described_class.post("/connections")).to eq(response)
    end
  end

  describe "#put" do
    it "calls a PUT request" do
      expect(described_class)
        .to receive(:request)
        .with(hash_including(method: :put, url: BASE_URL + "/connections"))
        .and_return(response)

      expect(described_class.put("/connections")).to eq(response)
    end
  end

  describe "#delete" do
    it "calls a DELETE request" do
      expect(described_class)
        .to receive(:request)
        .with(hash_including(method: :delete, url: BASE_URL + "/connections"))
        .and_return(response)

      expect(described_class.delete("/connections")).to eq(response)
    end
  end
end
