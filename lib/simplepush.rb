# frozen_string_literal: true

require_relative "simplepush/version"
require 'httparty'

class Simplepush

  include HTTParty

  base_uri 'https://api.simplepush.io'.freeze
  # For testing:
  # base_uri 'https://httpbin.org'.freeze
  format :json
  default_timeout 5 # 5 seconds
  debug_output $stdout

  # Send a plain-text message.
  #
  # This method is blocking.
  #
  # If password and salt are provided, then message and title will be encrypted.
  def send(key, title, message, password = nil, salt = '1789F0B8C4A051E5', event = nil)
    raise "Key and message argument must be set" unless key && message

    payload = {}
    payload[:key] = key
    payload[:msg] = message
    payload[:event] = event if event
    payload[:title] = title if title

    if password
      require 'openssl'
      payload[:encrypted] = true

      cipher = OpenSSL::Cipher::AES.new(128, :CBC)
      cipher.encrypt
      cipher.key = [Digest::SHA1.hexdigest(password + salt)[0,32]].pack "H*"

      # Set random_iv and store as payload
      payload[:iv] = cipher.random_iv.unpack("H*").first.upcase

      # Automatically uses PKCS7
      payload[:msg] = Base64.urlsafe_encode64(cipher.update(payload[:msg]) + cipher.final)

      if title
        cipher.encrypt
        payload[:title] = Base64.urlsafe_encode64(cipher.update(payload[:title]) + cipher.final)
      end
    end

    return self.class.post('/send', body: payload)
  end

  def self.send(...)
    Simplepush.new.send(...)
  end

end
