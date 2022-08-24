# frozen_string_literal: true

require_relative 'simplepush/version'
require 'httparty'
require_relative 'integrations/simplepush_notifier'

class Simplepush

  include HTTParty

  base_uri 'https://api.simplepush.io'.freeze
  # For testing:
  # base_uri 'https://httpbin.org'.freeze

  # Don't override format use from Content-Type
  # format :json

  default_timeout 5 # 5 seconds
  # debug_output $stdout # Uncomment to get detailled httparty log output to stdout

  # If password and salt are provided, then message and title will be encrypted.
  def initialize(key, password = nil, salt = '1789F0B8C4A051E5')
    raise "Key must be set" unless key
    @key = key
    @cipher_key = [Digest::SHA1.hexdigest(password + salt)[0,32]].pack "H*" if password
  end

  #
  # Send the given title/message.
  #
  # This method is blocking.
  #
  def send(title, message, event = nil)
    raise "Key and message argument must be set" unless message

    payload = {}
    payload[:key] = @key
    payload[:msg] = message.to_s
    payload[:event] = event.to_s if event
    payload[:title] = title.to_s if title

    if @cipher_key
      require 'openssl'
      payload[:encrypted] = true

      cipher = OpenSSL::Cipher::AES.new(128, :CBC)
      cipher.encrypt
      cipher.key = @cipher_key

      # Set random_iv and store as payload
      payload[:iv] = cipher.random_iv.unpack("H*").first.upcase

      # Automatically uses PKCS7
      payload[:msg] = Base64.urlsafe_encode64(cipher.update(payload[:msg]) + cipher.final)

      if title
        cipher.encrypt # Restart cipher
        payload[:title] = Base64.urlsafe_encode64(cipher.update(payload[:title]) + cipher.final)
      end
    end

    return self.class.post('/send', body: payload)
  end

end
