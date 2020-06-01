class Customers::RegistrationsController < Devise::RegistrationsController
  def create
    super
    email    = params[:customer]["email"]
    customer = Customer.find_by(email: email)

    response = SaltedgeClient.create_customer(email)

    customer.customer_id = response.dig("data", "id")
    customer.save
  end
end
