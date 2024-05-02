# Simplepush Gem for Ruby

This is a simple httparty wrapper for [SimplePush.io](https://SimplePush.io).

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

*Note:* The maximum amount of data which can be send using SimplePush is restricted. The usable payload is dependent on the target platform. It is safe to consider 1024 bytes for title and message combined. If you send too much data then you will get a 406 ('Not Acceptable') response.

## Asynchronous send

See [example/async.rb](example/async.rb)

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

    response = simplepush.send(title, message, event)
    if !response.success?
      Rails.logger.error "SimplePush failed: " + response.inspect
    end
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

## Usage with Encryption Notification Gem

Since 0.7.0, this Gem provides an integration with the [Exception Notification Gem](https://github.com/smartinez87/exception_notification). To enable this, add the following to your `environment.rb`:

```ruby
# production.rb
config.middleware.use ExceptionNotification::Rack, simplepush: {
  title_prefix: "[Crash in #{Rails.application.class.module_parent.name}] "
}
```

This depends on the credentials defined above. Exceptions which hit the production are then reported via Simplepush.

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
 - 0.7.0 Added support for [Exception Notification Gem](https://github.com/smartinez87/exception_notification)
 - 0.7.1 Fixed incorrect content-type handling.
 - 0.7.2 Bump dependencies because of vulnerability in httparty
 - 0.7.3 Fix OpenSSL cipher needing key again under Ruby >= 3.0, bump dependencies
 - 0.7.4 Fix message length restrictions for Exception Notification
 - 0.7.5 Make more robust again missing credentials

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/coezbek/simplepush

## License

MIT
