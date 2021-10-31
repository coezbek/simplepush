# Simplepush Gem for Ruby

This is a simple httparty wrapper for [SimplePush.io](SimplePush.io).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simplepush'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install simplepush
```

Add as a dependency:

```ruby
require 'simplepush'
```

## Usage

```ruby
# From example/example.rb
require 'simplepush'

Simplepush.new('<your key>').send("Title", "Message") # Unenrypted

Simplepush.new('<your key>', "<pass>", "<salt>").send("Title", "Message") # Enrypted

```

## Asynchronous send

The following does not work... `#TODO`

```ruby
require 'async' # gem 'async'

s = Simplepush.new('<your key>')

Sync do
  100.times do |i|
    Async do
      s.send("Title", i.to_s) # Unenrypted
    end
  end
end
```

## Usage in Rails

To use in Rails, you need (should?) use a worker gem to avoid that notification calls are blocking your users.

For instance using ActiveJob you could define:

```ruby
class SimplepushJob < ApplicationJob
  queue_as :default

  def perform(title, message, event=nil)

    simplepush = Rails.cache.fetch("simplepush", expires_in: 1.hour) do
      cred = Rails.application.credentials.simplepush
      Simplepush.new(cred[:key], cred[:pass], cred[:salt])
    end

    simplepush.send(title, message, event)
  end
end
```

This takes credentials from Rails `credentials.yml.enc`, which you can edit using `rails credentials:edit`. Add the following:

```yml
simplepush:
  key: <your key>
  pass: <your password>
  salt: <your salt>
```

In your code you can then dispatch messages to SimplePush using:

```ruby
SimplepushJob.perform_later("My app", "User #{current_user.email} perform admin action...")
```

## Example of query

The following is a sample of the query as it is produced:

```json
{
  "args": {},
  "data": "",
  "files": {},
  "form": {
    "encrypted": "true",
    "iv": "CEEFFBE72CC70DF45480DDAC775743B6",
    "key": "<the key, the key>",
    "msg": "szR70wqD9g8T2nX0FRZwoQ=="
  },
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
    "Content-Length": "94",
    "Content-Type": "application/x-www-form-urlencoded",
    "Host": "httpbin.org",
    "User-Agent": "Ruby",
    "X-Amzn-Trace-Id": "Root=1-617714e4-08fc2a3f349df4203121ce0e"
  },
  "json": null,
  "origin": "91.32.103.70",
  "url": "https://httpbin.org/post"
}
```

## Todos

 - [x] Encrypted Messages
 - [x] Processing responses
 - [x] Async calls
 - [x] Example how to integrate into rails to notify of failures

## Changelog

 - 0.5.0 Initial Commits
 - 0.6.0 Changing API to cache keys, better examples

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/coezbek/simplepush

## License

MIT
