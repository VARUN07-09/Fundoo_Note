class AddOtpToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :otp, :string
    add_column :users, :otp_expiry, :datetime
  end
end
