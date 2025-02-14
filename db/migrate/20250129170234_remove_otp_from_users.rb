class RemoveOtpFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :otp, :string
    remove_column :users, :otp_expiry, :datetime
  end
end
