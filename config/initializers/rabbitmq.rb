require 'bunny'

# Establish RabbitMQ connection
RABBITMQ = Bunny.new(automatically_recover: true)
RABBITMQ.start

# Create a channel for communication
RABBITMQ_CHANNEL = RABBITMQ.create_channel

# Create an exchange (direct exchange)
EXCHANGE = RABBITMQ_CHANNEL.direct('email_exchange')

# Define a queue and bind it to the exchange
EMAIL_QUEUE = RABBITMQ_CHANNEL.queue('email_notifications')
EMAIL_QUEUE.bind(EXCHANGE, routing_key: 'email_notifications')

puts "🐰 RabbitMQ connected, exchange and queue are ready!"
