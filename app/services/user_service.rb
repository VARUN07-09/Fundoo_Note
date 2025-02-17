class UserService
  def self.send_otp(user)
    # If a string (email) is passed, look up the User.
    user = User.find_by(email: user) if user.is_a?(String)
    return { success: false, error: "User not found" } unless user

    # Generate and store OTP.
    otp_data = user.generate_otp # returns { otp: "123456", otp_expiry: "2025-02-14 13:58:45 +0530" }

    # Publish OTP message to RabbitMQ.
    EXCHANGE.publish({
      email: user.email,
      type: "otp_email",
      otp: otp_data[:otp],
      otp_expiry: otp_data[:otp_expiry]
    }.to_json, routing_key: 'email_notifications', persistent: true)

    { success: true, message: 'OTP request sent to RabbitMQ' }
  end

  def self.verify_otp_and_reset_password(email, otp, new_password)
    user = User.find_by(email: email)
    return { success: false, error: "User not found" } unless user
    return { success: false, error: "Invalid or expired OTP" } unless user.valid_otp?(otp)

    # Validate password before updating
    user.password = new_password
    if user.valid?
      user.save
      user.clear_otp

      # Publish password reset confirmation email to RabbitMQ.
      EMAIL_QUEUE.publish({ email: user.email, type: "password_reset" }.to_json)

      { success: true, message: "Password reset successfully. A confirmation email has been sent." }
    else
      { success: false, error: user.errors.full_messages.join(", ") }
    end
  end

  def self.register(params)
    user = User.new(params)
    if user.save
      { success: true, user: user }
    else
      { success: false, error: user.errors.full_messages.join(", ") }
    end
  end

  def self.login(email, password)
    user = User.find_by(email: email)
    return { success: false, error: "Invalid email or password" } unless user&.authenticate(password)

    token = JwtService.encode({ user_id: user.id })
    { success: true, user: user, token: token }
  end

  def self.fetch_profile(user)
    return { success: false, error: "Unauthorized" } unless user
    { success: true, user: user }
  end
end
