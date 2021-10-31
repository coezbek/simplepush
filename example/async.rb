
require_relative 'config.rb'

config = load_config
simplepush = Simplepush.new(config[:key])

n = 10
if 3 >= RUBY_VERSION.split(".").first.to_i

  require 'async'
  Sync do
    n.times do |i|
      Async do
       simplepush.send("Asynchronous sending with Async", i.to_s)
      end
    end
  end # join here

else

  threads = Array.new(n) { |i|
    Thread.new {
      simplepush.send("Asynchronous sending with Threads", i.to_s)
    }
  }
  threads.each(&:join)

end