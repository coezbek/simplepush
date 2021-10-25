
require_relative '../lib/simplepush'

puts Simplepush.send('<key>', "Title", "Message", "<pass>", "<salt>")