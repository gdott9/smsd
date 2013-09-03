require 'optparse'

module SMSd
  class CLI
    class Options
      def self.parse(args)
        options = {}

        parser = ::OptionParser.new do |opts|
          opts.banner = "Usage: smsd [options]"

          opts.separator ""
          opts.separator "Specific options:"

          opts.on('-l', '--locale LOCALE',
                  'Define the language of the script') do |locale|
            options[:locale] = locale.to_sym
          end

          opts.separator ""
          opts.separator "Common options:"

          opts.on('-h', '--help', 'Show this message') do
            puts opts
            exit
          end

          opts.on_tail('--version', 'Show version') do
            puts "#{opts.program_name} #{SMSd::VERSION}"
            exit
          end
        end

        parser.parse!(args)
        options
      end
    end
  end
end
