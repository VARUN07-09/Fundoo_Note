# FactoryBot.define do
#     factory :user do
#       name { Faker::Name.name }
#       email { Faker::Internet.email }
#       phone_no { Faker::PhoneNumber.cell_phone }
#       password { 'password' }
#     end
#   end
  
FactoryBot.define do
    factory :user do
      # add necessary attributes for a valid user
      name { "baletine"}
      email { "test@example.com" }
      password { "P@ssword123" }
      phone_no {7707908940}
      # Add any additional fields as necessary
    end
  end
  