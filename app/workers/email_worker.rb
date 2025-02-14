class EmailWorker
  def self.start
    EMAIL_QUEUE.subscribe(manual_ack: true, block: true) do |_delivery_info, _properties, body|
      
      begin
        data = JSON.parse(body)
        user = User.find_by(email: data["email"])

        if user
          case data["type"]
          when "otp_email"
            UserMailer.send_otp_email(user, { otp: data["otp"], otp_expiry: data["otp_expiry"] }).deliver_now
          when "password_reset"
            UserMailer.password_reset_successful(user).deliver_now
          end
        end

        _delivery_info.channel.ack(_delivery_info.delivery_tag)
      rescue JSON::ParserError
        _delivery_info.channel.nack(_delivery_info.delivery_tag)
      end
    end
  end
end


if Rails.env.production? || Rails.env.development?
  Thread.new { EmailWorker.start }
end

