module SMSd
  class SMS
    attr_accessor :id, :from, :to, :message, :datetime
    attr_reader :errors

    def initialize(attributes)
      attributes.each do |attr, value|
        setter = "#{attr}="
        send(setter, value) if respond_to?(setter)
      end
    end

    def valid?
      @errors = {}

      @errors[:too_old] = 'Message too old' if datetime.to_time < Time.now - (5 * 60)
      @errors[:short_number] = 'Phone number too short' if phone_number.length < 6

      @errors.empty?
    end
  end
end
