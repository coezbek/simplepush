# Only load this file if exception_notification Gem is bundled
return unless Gem.loaded_specs.has_key? 'exception_notification'

module ExceptionNotifier

  class SimplepushNotifier < BaseNotifier

    attr_reader :client, :default_options

    def initialize(options)
      cred = Rails.application.credentials.simplepush

      if !cred
        Rails.logger.error "Simplepush credentials not found. Please add simplepush credentials to your credentials file."
        return
      end

      @client = Simplepush.new(cred[:key], cred[:pass], cred[:salt])
      @default_options = options
    end

    def call(exception, options = {})
      if !@client
        event = SimplepushExceptionEvent.new(exception, options.reverse_merge(default_options))
        @client.send(event.formatted_title, event.formatted_body)
      end
    end

    #
    # This class is responsible to format title and message from given exception and options.
    #
    # Adapted from https://github.com/smartinez87/exception_notification/blob/master/lib/exception_notifier/datadog_notifier.rb
    #   Version: committed on 27 Dec 2019
    #
    # Released under MIT license: https://github.com/smartinez87/exception_notification/blob/master/MIT-LICENSE
    #
    class SimplepushExceptionEvent
      include ExceptionNotifier::BacktraceCleaner

      MAX_TITLE_LENGTH = 120
      MAX_VALUE_LENGTH = 300
      MAX_BACKTRACE_SIZE = 3
      MAX_TOTAL_SIZE_BYTES = 1024

      attr_reader :exception,
                  :options

      def initialize(exception, options)
        @exception = exception
        @options = options
      end

      def request
        @request ||= ActionDispatch::Request.new(options[:env]) if options[:env]
      end

      def controller
        @controller ||= options[:env] && options[:env]['action_controller.instance']
      end

      def backtrace
        @backtrace ||= exception.backtrace ? clean_backtrace(exception) : []
      end

      def title_prefix
        options[:title_prefix] || ''
      end

      def formatted_title
        title =
          "#{title_prefix}#{controller_subtitle} (#{exception.class}) #{exception.message.inspect}"

        truncate(title, MAX_TITLE_LENGTH)
      end

      def formatted_body
        text = []

        text << formatted_backtrace
        text << formatted_request if request
        text << formatted_session if request

        text = text.join("\n------------------\n")

        if text.bytesize >= MAX_TOTAL_SIZE_BYTES
          # puts "Text is too long (#{text.bytesize} bytes >= MAX_TOTAL_SIZE), need to truncate"
          
          # if truncate bytes is available
          if text.respond_to?(:truncate_bytes) && false            
            text = text.truncate_bytes(MAX_TOTAL_SIZE_BYTES)
          else
            text = text[0...(MAX_TOTAL_SIZE_BYTES/2)]
          end
          # puts "Text after truncate is #{text.bytesize} bytes <= MAX_TOTAL_SIZE"
        end

        text
      end

      def formatted_key_value(key, value)
        "#{key}: #{value}"
      end

      def formatted_request
        text = []
        text << '# Request'
        text << formatted_key_value('URL', request.url)
        text << formatted_key_value('HTTP Method', request.request_method)
        text << formatted_key_value('IP Address', request.remote_ip)
        text << formatted_key_value('Parameters', request.filtered_parameters.inspect)
        text << formatted_key_value('Timestamp', Time.current)
        text << formatted_key_value('Server', Socket.gethostname)
        text << formatted_key_value('Rails root', Rails.root) if defined?(Rails) && Rails.respond_to?(:root)
        text << formatted_key_value('Process', $PROCESS_ID)
        text.join("\n")
      end

      def formatted_session
        text = []
        text << '# Session'
        text << formatted_key_value('Data', request.session.to_hash)
        text.join("\n")
      end

      def formatted_backtrace
        size = [backtrace.size, MAX_BACKTRACE_SIZE].min

        text = []
        text << '# Backtrace'
        text << '````'
        size.times { |i| text << backtrace[i] }
        text << '````'
        text.join("\n")
      end

      def truncate(string, max)
        string.length > max ? "#{string[0...max]}..." : string
      end

      def inspect_object(object)
        case object
        when Hash, Array
          truncate(object.inspect, MAX_VALUE_LENGTH)
        else
          object.to_s
        end
      end

      def controller_subtitle
        "#{controller.controller_name} #{controller.action_name}" if controller
      end
    end
  end
end