module SMSd
  class AnsweringMachine
    attr_accessor :actions, :default_action

    def initialize(default_answer = nil, &block)
      self.actions = []
      self.default_action = Action.new(nil, default_answer, &block)
    end

    def add_action(regexp, answer = nil, &block)
      self.actions << Action.new(regexp, answer, &block)
    end

    def execute(from, to, message)
      actions.each do |action|
        return action.answer(from, to, message) if message =~ action.regexp
      end

      default_action.answer(from, to, message)
    end
  end
end
