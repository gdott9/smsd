module SMSd
  class AnsweringMachine
    class Action
      attr_accessor :regexp, :action

      def initialize(regexp, answer = nil, &block)
        self.regexp = regexp
        self.action = (block_given? ? block : answer)
      end

      def answer(from, to, message)
        case action
        when Proc
          action.call(from, to, message)
        else
          action
        end
      end
    end
  end
end
