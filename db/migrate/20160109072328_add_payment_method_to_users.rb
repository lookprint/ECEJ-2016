class AddPaymentMethodToUsers < ActiveRecord::Migration
  def change
    add_column :users, :payment_method, :string, default: nil
  end
end
