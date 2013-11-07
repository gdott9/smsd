#!/usr/bin/env ruby

require 'smsd'
require 'net/http'

cli = SMSd::CLI.new(ARGV) do
  machine = SMSd::AnsweringMachine.new('I did not understand.',
    too_old: 'Your message is too old',
    short_number: 'The phone number you are using is too short')

  machine.add_action(/ping/i, 'PONG')
  machine.add_action(/free/i) do
    `free`
  end
  machine.add_action(/myip/i) do
    Net::HTTP.get('icanhazip.com', '/').chomp
  end

  machine
end

cli.modem.prefered_storage('SM')
cli.run
