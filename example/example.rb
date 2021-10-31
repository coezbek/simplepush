
require_relative 'config.rb'

config = load_config

puts "Please enter your message"
message = gets.strip

puts "Should this message be encrypted? (y or n)"

simplepush = if gets =~ /n/i
  Simplepush.new(config[:key])
else
  Simplepush.new(config[:key], config[:pass], config[:salt])
end

simplepush.send('Message from Example.rb', message)

