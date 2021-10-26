# Simplepush Gem for Ruby

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/simplepush`. To experiment with that code, run `bin/console` for an interactive prompt.

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

Simplepush.send('<your key>', "Title", "Message") # Unenrypted

Simplepush.send('<your key>', "Title", "Message", "<pass>", "<salt>") # Enrypted

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
 - [ ] Async calls

## Changelog

 - 0.5.0 Initial Release

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/coezbek/simplepush

## License

MIT
