class Biju::Sms
  attr_reader :errors

  def valid?
    @errors = {}

    @errors[:too_old] = 'Message too old' if datetime.to_time < Time.now - (5 * 60)
    @errors[:short_number] = 'Phone number too short' if phone_number.length < 6

    @errors.empty?
  end
end
