module SMSd
  module Backend
    class Gammu
      def initialize
      end

      def close
      end

      def message
      end

      def send(sms)
        IO.popen("gammu-sms-inject TEXT #{sms.to}", 'w') do |cmd|
          cmd.write sms.message
        end
      end

      def delete(sms)
      end

      def phone_numbers
      end

      def phone_number
      end
    end
  end
end
