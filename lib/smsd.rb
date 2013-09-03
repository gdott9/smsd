require 'i18n'

require 'smsd/version'
require 'smsd/cli'
require 'smsd/cli/options'
require 'smsd/answering_machine'
require 'smsd/answering_machine/action'

module SMSd
  def self.init_i18n
    I18n.load_path = Dir[File.join(File.dirname(__FILE__),
                         '..', 'locale', '*.yml')]
  end

  def self.locale=(locale)
    I18n.locale = locale
  end
end
