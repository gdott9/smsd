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
        sleep 5
        break if @terminate

        modem.messages.each do |sms|
          handle_message sms unless check_number(
            sms.phone_number, sms.type_of_address)
        end
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

    def check_number(number, type_of_address)
      phone_numbers.each do |phone_number|
        return true if phone_number[:number] == number &&
          phone_number[:type_of_address] == type_of_address
      end unless phone_numbers.nil?

      false
    end

    def phone_numbers
      @phone_numbers ||= modem.phone_numbers
    rescue Biju::AT::CmeError
      nil
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
      to = (phone_numbers.empty? ? phone_numbers.first[:number] : nil)
      message = machine.execute(sms.phone_number, to, sms.message)

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
