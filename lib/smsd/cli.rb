module SMSd
  class CLI
    attr_accessor :machine, :options

    def initialize(args)
      self.options = Options.parse(args)

      SMSd.init_i18n
      SMSd.locale = options[:locale] || :fr

      define_actions

      puts machine.execute(ARGV[0], ARGV[1], ARGV[2])
    end

    def define_actions
      self.machine = AnsweringMachine.new(I18n.t(:default_answer))

      machine.add_action(/bonjour/i, 'Bonjour !!')
      machine.add_action(/quoi/i) do |from, to, message|
        I18n.t(:what, from: from, to: to, message: message)
      end
    end
  end
end
