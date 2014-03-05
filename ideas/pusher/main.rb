#require "websocket-native"
require "pusher-client"


puts "starting client"
client= PusherClient::Socket.new("de504dc5763aeef9ff52")
client.connect(true)
PusherClient.logger.level= Logger::Severity::WARN

puts "subscribing to channels"
# CHANNEL: live_trades, EVENT: trade, PUSHER KEY: de504dc5763aeef9ff52
live_trades= client.subscribe("live_trades")
# CHANNEL: order_book, EVENT: data, PUSHER KEY: de504dc5763aeef9ff52
# order_book= client.subscribe("order_book")

puts "binding events"
live_trades.bind("trade") do |data|
  json= JSON.parse(data)
  p [Time.now.to_i, json["price"], json["amount"]]
end

=begin
order_book.bind("data") do |data|
  puts data
end
=end

puts "waiting for data"
while true do
  sleep 1
end

