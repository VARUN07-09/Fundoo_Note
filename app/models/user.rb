class User < ApplicationRecord

  
  has_secure_password 

  

  validates :name, presence: true, format: { with: /\A[a-zA-Z\s]+\z/, message: "only allows letters and spaces" }
  validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "must be a valid email address" }
  validates :password, presence: true, length: { minimum: 8 }, format: { 
    with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).+\z/, 
    message: "must include at least one uppercase letter, one lowercase letter, one digit, and one special character" 
  }
  validates :phone_no, presence: true, format: { with: /\A[6-9]\d{9}\z/, message: "must be a valid Indian phone number (10 digits, starting with 6, 7, 8, or 9)" }

  has_many :notes, dependent: :destroy


  attr_accessor :otp_expiry

  def generate_otp
    otp = rand(100000..999999).to_s
    expiry = 10.minutes.from_now
    self.class.store_otp(email, otp, expiry)  # Pass expiry
    expiry_in_kolkata = expiry.in_time_zone('Asia/Kolkata')  # Convert expiry time to IST
    { otp: otp,otp_expiry: expiry_in_kolkata.to_s }
  end
  
  

  def valid_otp?(entered_otp)
    otp_data = self.class.fetch_otp(email)
    return false unless otp_data
    return false if Time.current > otp_data[:expires_at]
    otp_data[:otp] == entered_otp
  end



  
  def clear_otp
    self.class.remove_otp(email)
  end

  private

  # Class-level OTP store methods
  def self.otp_store
    @otp_store ||= {}  
  end

  def self.store_otp(email, otp,expiry)
    otp_store[email] = { otp: otp, expires_at: 2.minutes.from_now }
  end

  def self.fetch_otp(email)
    otp_store[email]
  end

  def self.remove_otp(email)
    otp_store.delete(email)
  end
end


