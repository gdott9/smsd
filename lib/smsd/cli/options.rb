require 'optparse'

module SMSd
  class CLI
    class Options
      def self.parse(args)
        options = {}

        parser = ::OptionParser.new do |opts|
          opts.banner = 'Usage: smsd [options] MODEM'

          opts.separator ''
          opts.separator 'Specific options:'

          opts.on('-d', '--[no-]daemonize',
                  'Run in the background') do |daemon|
            options[:daemonize] = daemon
          end

          opts.on('-l', '--log-file FILE', 'Define log file') do |logfile|
            options[:logfile] = logfile
          end

          opts.on('-s', '--[no-]syslog', 'Use syslog as logger') do |syslog|
            options[:syslog] = syslog
          end

          opts.on('-p', '--pin PIN', 'Specify the SIM PIN') do |pin|
            options[:pin] = pin
          end

          opts.separator ''
          opts.separator 'Common options:'

          opts.on_tail('-h', '--help', 'Show this message') do
            puts opts
            exit
          end

          opts.on_tail('--version', 'Show version') do
            puts "#{opts.program_name} #{SMSd::VERSION}"
            exit
          end
        end

        begin
          parser.parse!(args)

          options[:modem] = args.first
          raise OptionParser::MissingArgument,
                'modem not specified' if options[:modem].nil?
        rescue OptionParser::MissingArgument, OptionParser::InvalidOption => e
          puts e.message
          puts parser
          exit
        end

        options
      end
    end
  end
end
