module SMSd
  module Backend
    class Biju
      attr_accessor :modem

      def initialize(modem, options)
        @modem = Biju::Hayes.new(modem, options)
      end

      def close
        modem.close
      end

      def messages
        modem.messages.map do |sms|
          if sms.is_a?(Biju::Sms)
            sms.to_smsd
          else
            modem.delete sms.id
            #logger.error sms.to_s

            nil
          end
        end.compact
      end

      def send(sms)
        modem.send(sms.to_biju)
      end

      def delete(sms)
        modem.delete(sms.id)
      end

      def phone_numbers
        @phone_numbers ||= modem.phone_numbers
      rescue Biju::AT::CmeError
        []
      end

      def phone_number
        @phone_number ||= (!phone_numbers.empty? ? phone_numbers.first[:number] : nil)
      end

      module Convert
        module Biju
          def to_smsd
            ::SMSd::SMS.new(
              id: id,
              from: phone_number,
              message: message,
              datetime: datetime)
          end
        end

        module SMSd
          def to_biju
            ::Biju::Sms.new(
              phone_number: self.to,
              message: self.message.to_s[0, 160])
          end
        end
      end
    end
  end
end

Biju::Sms.include SMSd::Backend::Biju::Convert::Biju
SMSd::SMS.include SMSd::Backend::Biju::Convert::SMSd
