module SMSd
  class AnsweringMachine
    attr_accessor :actions, :default_action, :specific_actions

    def initialize(default_answer = nil, specific_actions = {}, &block)
      self.actions = []
      self.default_action = Action.new(nil, default_answer, &block)

      self.specific_actions = {}
      specific_actions.each do |key, value|
        self.specific_actions[key] = Action.new(nil, value)
      end
    end

    def add_action(regexp, answer = nil, &block)
      actions << Action.new(regexp, answer, &block)
    end

    def execute_action(action, from, to, message)
      specific_actions[action].answer(from, to, message) if specific_actions.key?(action)
    end

    def execute(from, to, message)
      actions.each do |action|
        return action.answer(from, to, message) if message =~ action.regexp
      end

      default_action.answer(from, to, message)
    end
  end
end
