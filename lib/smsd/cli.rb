require 'biju'
require 'logger'

module SMSd
  class CLI
    attr_accessor :machine
    attr_reader :modem, :options, :logger

    def initialize(args = [], &block)
      @options = Options.parse(args)

      self.machine = yield block if block_given?

      init_logger
      @modem = Biju::Hayes.new(options[:modem], pin: options[:pin])
    end

    def run
      catch_signals
      Process.daemon if options[:daemonize]

      loop do
        break if @terminate

        modem.messages.each do |sms|
          handle_message sms
        end

        sleep 5
      end
      modem.modem.close
    end

    private

    def init_logger
      @logger = Logger.new(
        Util::MultiIO.new(STDOUT,
                          File.open(@options[:logfile] || 'smsd.log', 'a')))

      logger.formatter = proc do |severity, datetime, progrname, msg|
        "#{$PROGRAM_NAME}: #{datetime} [#{severity}] #{msg}\n"
      end
    end

    def catch_signals
      signal_term =  proc { @terminate = true }
      Signal.trap('SIGTERM', signal_term)
      Signal.trap('SIGINT', signal_term)
    end

    def handle_message(sms)
      if sms.valid?
        send_answer(sms)
      else
        logger.warn "#{sms}: #{sms.errors.join(',')}"
      end
      modem.delete(sms.id)
    end

    def send_answer(sms)
      message = machine.execute(sms.phone_number, nil, sms.message)

      if message.nil? || message == ''
        log = 'Empty answer'
      else
        modem.send(Biju::Sms.new(
          phone_number: sms.phone_number, message: message))
        log = message
      end

      logger.info "#{sms}: #{log}"
    end
  end
end
