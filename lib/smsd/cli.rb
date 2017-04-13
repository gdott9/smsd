require 'biju'
require 'logger'
require 'date'

module SMSd
  class CLI
    attr_accessor :machine, :last_pong
    attr_reader :backend, :options, :logger, :running_since

    def initialize(args = [], &block)
      @options = Options.parse(args)

      self.machine = yield block if block_given?

      init_logger
      redirect_output
      @backend = Backend::Biju.new(options[:modem], pin: options[:pin])
    rescue Errno::ENOENT => e
      logger.warn e.message
      exit
    end

    def run
      @running_since = DateTime.now

      catch_signals
      Process.daemon(false, !@options[:output].nil?) if options[:daemonize]

      loop do
        pong if options[:alive]

        sleep 5
        break if @terminate

        backend.messages.each do |sms|
          handle_message sms unless check_number(sms.from)
        end
      end
      backend.close
    end

    private

    def init_logger
      if @options[:syslog]
        @logger = Syslog::Logger.new($PROGRAM_NAME)
      else
        @logger = Logger.new(
          Util::MultiIO.new(STDOUT,
                            File.open(@options[:logfile] || 'smsd.log', 'a')))

        logger.formatter = proc do |severity, datetime, progrname, msg|
          "#{$PROGRAM_NAME}: #{datetime} [#{severity}] #{msg}\n"
        end
      end
    end

    def redirect_output
      if @options[:output]
        output_file = File.new(@options[:output], 'a')
        $stdout.reopen(output_file)
        $stderr.reopen(output_file)
      end
    end

    def catch_signals
      signal_term =  proc { @terminate = true }
      Signal.trap('SIGTERM', signal_term)
      Signal.trap('SIGINT', signal_term)
    end

    def check_number(number)
      backend.phone_number == number
    end

    def handle_message(sms)
      if sms.valid?
        send_answer(sms)
      else
        send_errors(sms)
      end
      backend.delete sms
    end

    def send_answer(sms)
      message = machine.execute(sms.from, backend.phone_number, sms.message)

      send_sms(sms, message)
    end

    def send_errors(sms)
      logger.warn "#{sms}: #{sms.errors.values.join(',')}"

      errors = sms.errors.keys.map do |error|
        machine.execute_action(error, sms.from, backend.phone_number, sms.message)
      end
      message = errors.compact.join(' ')

      send_sms(sms, message) unless errors.include?(false)
    end

    def send_sms(sms, message)
      if message.nil? || message == ''
        log = 'Empty answer'
      else
        backend.send(SMS.new(to: sms.from, message: message))
        log = "Sent answer \"#{message}\""
      end

      logger.info "#{sms}: #{log}"
    end

    def pong
      if last_pong.nil? || last_pong < (DateTime.now - 1)
        now = DateTime.now

        logger.info "I have been alive for #{(now - running_since).to_f.round} days (#{running_since})."
        self.last_pong = now
      end
    end
  end
end
