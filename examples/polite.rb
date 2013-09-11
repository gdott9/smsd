#!/usr/bin/env ruby

require 'smsd'

cli = SMSd::CLI.new(ARGV) do
  machine = SMSd::AnsweringMachine.new('I didn\'t understand your message.')

  machine.add_action(/hello|hi/i, 'Ahoy !!')
  machine.add_action(/what/i) do |from, to, message|
    "The phone number #{from} wrote '#{message}' to #{to}"
  end

  machine
end

cli.run

