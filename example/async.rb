
require_relative 'config.rb'

config = load_config
simplepush = Simplepush.new(config[:key])

require 'async'
require 'benchmark'
require 'open-uri'
require 'httparty'

n = 3
Benchmark.bm(20) do |b|

  b.report "Sequential" do
    n.times do |i|
      HTTParty.get("https://httpbin.org/delay/1.6")
    end
  end

  b.report "Threads + HTTParty" do
    threads = Array.new(n) { |i|
      Thread.new {
        HTTParty.get("https://httpbin.org/delay/1.6")
      }
    }
    threads.each(&:join)
  end

  b.report "Async + HTTParty" do
    Async do |task|
      n.times do |i|
        task.async do
          HTTParty.get("https://httpbin.org/delay/1.6")
        end
      end
    end
  end

  b.report "Async + open-uri" do
    Async do |task|
      n.times do |i|
        task.async do
          URI.open("https://httpbin.org/delay/1.6")
        end
      end
    end
  end

end
