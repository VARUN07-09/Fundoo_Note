require 'rails_helper'

RSpec.describe UserService, type: :service do
  let(:user) { create(:user, email: 'test@example.com') }
  let(:valid_otp) { '123456' }
  let(:invalid_otp) { '000000' }

  describe '.send_otp' do
    it 'sends OTP to RabbitMQ' do
      expect(EXCHANGE).to receive(:publish) do |message, opts|
        parsed = JSON.parse(message)
        expect(parsed).to include("otp" => kind_of(String))
        expect(parsed["email"]).to eq(user.email)
        expect(opts).to eq({ persistent: true, routing_key: 'email_notifications' })
      end

      result = UserService.send_otp(user.email)
      expect(result[:success]).to eq(true)
      expect(result[:message]).to eq('OTP request sent to RabbitMQ')
    end
  end

  describe '.verify_otp_and_reset_password' do
    it 'verifies OTP and resets password' do
      # Stub OTP verification on any User instance.
      allow_any_instance_of(User).to receive(:valid_otp?).with(valid_otp).and_return(true)
      
      # Use a new password that meets the validation criteria.
      new_valid_password = 'NewPass1!'

      result = UserService.verify_otp_and_reset_password(user.email, valid_otp, new_valid_password)
      expect(result[:success]).to eq(true)
      expect(result[:message]).to eq('Password reset successfully. A confirmation email has been sent.')
    end

    it 'fails if OTP is invalid or expired' do
      result = UserService.verify_otp_and_reset_password(user.email, invalid_otp, 'NewPass1!')
      expect(result[:success]).to eq(false)
      expect(result[:error]).to eq('Invalid or expired OTP')
    end
  end
end
