class UserMailer < ApplicationMailer
  default from: 'varun91thakur@gmail.com' 

  def send_otp_email(user, otp_details)
    @user = user
    @otp = otp_details[:otp]         # Extract OTP from the hash
    @otp_expiry = otp_details[:otp_expiry].to_datetime   # Extract OTP expiry from the hash
    mail(to: @user.email, subject: 'Your OTP Code')
  end

  def password_reset_successful(user)
    @user = user
    mail(to:@user.email,subject:'Your password has been successfully Reset')
  end  
end
