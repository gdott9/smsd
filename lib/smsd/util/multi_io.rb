module SMSd::Util
  class MultiIO
    def initialize(*targets)
      @targets = targets
    end

    def write(*args)
      @targets.each { |t| t.write(*args); t.flush }
    end

    def close
      @targets.each(&:close)
    end
  end
end
