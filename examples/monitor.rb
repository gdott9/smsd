#!/usr/bin/env ruby

require 'smsd'
require 'net/http'

cli = SMSd::CLI.new(ARGV) do
  machine = SMSd::AnsweringMachine.new(I18n.t(:default_answer))

  machine.add_action(/ping/i, 'PONG')
  machine.add_action(/free/i) do
    `free`
  end
  machine.add_action(/myip/i) do
    Net::HTTP.get('icanhazip.com', '/').chomp
  end

  machine
end

cli.run
